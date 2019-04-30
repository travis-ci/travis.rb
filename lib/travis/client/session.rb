require 'travis/client'
require 'travis/version'

require 'faraday'
require 'faraday_middleware'
require 'travis/tools/system'
require 'travis/tools/assets'

begin
  require 'typhoeus/adapters/faraday' unless Travis::Tools::System.windows?
rescue LoadError
end

require 'json'

module Travis
  module Client
    class Session
      PRIMITIVE   = [nil, false, true]
      SSL_OPTIONS = { :ca_file => Tools::Assets['cacert.pem'] }

      include Methods
      attr_reader :connection, :headers, :access_token, :instruments, :faraday_adapter, :agent_info, :ssl
      attr_accessor :debug_http

      def initialize(options = Travis::Client::ORG_URI)
        @headers         = {}
        @cache           = {}
        @instruments     = []
        @agent_info      = []
        @config          = nil
        @faraday_adapter = defined?(Typhoeus) ? :typhoeus : :net_http
        @ssl             = SSL_OPTIONS

        options = { :uri => options } unless options.respond_to? :each_pair
        options.each_pair { |key, value| public_send("#{key}=", value) }

        raise ArgumentError, "neither :uri nor :connection specified" unless connection
        headers['Accept'] = 'application/vnd.travis-ci.2+json'
        set_user_agent
        check_ssl
      end

      def uri
        connection.url_prefix.to_s if connection
      end

      def agent_info=(info)
        @agent_info = [info].flatten.freeze
        set_user_agent
      end

      def ssl=(options)
        @ssl     = options.dup.freeze
        self.uri = uri if uri
      end

      def uri=(uri)
        clear_cache!
        self.connection = Faraday.new(:url => uri, :ssl => ssl) do |faraday|
          faraday.request  :url_encoded
          faraday.response :logger if debug_http
          faraday.adapter(*faraday_adapter)
        end
      end

      def faraday_adapter=(adapter)
        @faraday_adapter = adapter
        self.uri &&= uri
        set_user_agent
      end

      def access_token=(token)
        clear_cache!
        @access_token = token
        headers['Authorization'] = "token #{token}"
        headers.delete('Authorization') unless token
      end

      def connection=(connection)
        clear_cache!
        connection.headers.merge! headers
        @config     = nil
        @connection = connection
        @headers    = connection.headers
      end

      def headers=(headers)
        clear_cache!
        connection.headers = headers if connection
        @headers = headers
      end

      def find_one(entity, id = nil)
        raise Travis::Client::Error, "cannot fetch #{entity}" unless entity.respond_to?(:many) and entity.many
        return create_entity(entity, entity.id_field => id) if entity.id? id
        cached(entity, :by, id) { fetch_one(entity, id) }
      end

      def find_many(entity, args = {})
        raise Travis::Client::Error, "cannot fetch #{entity}" unless entity.respond_to?(:many) and entity.many
        cached(entity, :many, args) { fetch_many(entity, args) }
      end

      def find_one_or_many(entity, args = nil)
        raise Travis::Client::Error, "cannot fetch #{entity}" unless entity.respond_to?(:many) and entity.many
        cached(entity, :one_or_many, args) do
          path       = "/#{entity.many}"
          path, args = "#{path}/#{args}", {} unless args.is_a? Hash
          result     = get(path, args)
          one        = result[entity.one]

          if result.include? entity.many
            Array(one) + Array(result[entity.many])
          else
            one
          end
        end
      end

      def reset(entity)
        entity.attributes.clear
        entity
      end

      def reload(entity)
        reset(entity)
        result = fetch_one(entity.class, entity.id)
        entity.update_attributes(result.attributes) if result.attributes != entity.attributes
        result
      end

      def config
        @config ||= get_raw('/config')['config'] || {}
      end

      def load(data)
        result = {}
        (data || {}).each_pair do |key, value|
          entity      = load_entity(key, value)
          result[key] = entity if entity
        end
        result
      end

      def load_entity(key, value)
        type = Entity.subclass_for(key)
        if value.respond_to? :to_ary
          value.to_ary.map { |e| create_entity(type, e) }
        else
          create_entity(type, value)
        end
      rescue IndexError
      end

      def preload(list)
        list.group_by(&:class).each do |type, instances|
          next unless type.preloadable?
          ids = instances.map { |e| e.id unless e.complete? }.compact
          find_many(type, :ids => ids) if ids.any?
        end
        list
      end

      def get(*args)
        load get_raw(*args)
      end

      def delete(*args)
        load delete_raw(*args)
      end

      def patch(*args)
        load patch_raw(*args)
      end

      def post(*args)
        load post_raw(*args)
      end

      def put(*args)
        load put_raw(*args)
      end

      def get_raw(*args)
        raw(:get, *args)
      end

      def post_raw(*args)
        raw(:post, *args)
      end

      def put_raw(*args)
        raw(:put, *args)
      end

      def patch_raw(*args)
        raw(:patch, *args)
      end

      def delete_raw(*args)
        raw(:delete, *args)
      end

      def raw(verb, url, *args)
        url     = url.sub(/^\//, '')
        result  = instrumented(verb.to_s.upcase, url, *args) do
          if url !~ /^https?:/ or url.start_with? api_endpoint
            connection.public_send(verb, url, *args)
          else
            Faraday.public_send(verb, url, *args) { |r| r.headers.delete("Authorization") }
          end
        end

        case result.status
        when 0             then raise Travis::Client::SSLError, 'SSL error: could not verify peer'
        when 200..299      then JSON.parse(result.body) rescue result.body
        when 301, 303      then raw(:get, result.headers['Location'])
        when 302, 307, 308 then raw(verb, result.headers['Location'])
        when 401           then raise Travis::Client::NotLoggedIn,      'not logged in'
        when 403           then
          body = JSON.parse(result.body) rescue {}
          if body["error_type"] == "migrated_repository"
            raise Travis::Client::RepositoryMigrated, body["error_message"]
          else
            raise Travis::Client::NotLoggedIn,      'invalid access token'
          end
        when 404           then raise Travis::Client::NotFound,         result.body
        when 422           then raise Travis::Client::ValidationFailed, result.body
        when 400..499      then raise Travis::Client::Error,            "%s: %p" % [result.status, result.body]
        when 500..599      then raise Travis::Client::Error,            "server error (%s: %p)" % [result.status, result.body]
        else raise Travis::Client::Error, "unhandled status code #{result.status}"
        end
      end

      def inspect
        "#<#{self.class}: #{uri}>"
      end

      def clear_cache
        reset_entities
        clear_find_cache
        self
      end

      def clear_cache!
        reset_entities
        @cache.clear
        self
      end

      def session
        self
      end

      def instrument(&block)
        instruments << block
      end

      def private_channels?
        !!config['pusher']['private']
      end

      private

        def set_user_agent
          adapter = Array === faraday_adapter ? faraday_adapter.first : faraday_adapter
          adapter = adapter.to_s.capitalize.gsub(/_http_(.)/) { "::HTTP::#{$1.upcase}" }.gsub(/_http/, '::HTTP')
          headers['User-Agent'] = "Travis/#{Travis::VERSION} (#{Travis::Tools::System.description(agent_info)}) Faraday/#{Faraday::VERSION} #{adapter}/#{adapter_version(adapter)}"
        end

        def adapter_version(adapter)
          version = Object.const_get(adapter).const_get("VERSION")
          [*version].join('.')
        rescue Exception
          "unknown"
        end

        def instrumented(name, *args)
          name   = [name, *args.map(&:inspect)].join(" ") if args.any?
          result = nil
          chain  = instruments + [proc { |n,l| result = yield }]
          lift   = proc { chain.shift.call(name, lift) }
          lift.call
          result
        end

        def create_entity(type, data)
          return data if primitive?(data)
          data   = { type.id_field => data } if type.id? data
          id     = type.cast_id(data.fetch(type.id_field)) unless type.weak?
          entity = id ? cached(type, :id, id) { type.new(self, id) } : type.new(self, nil)
          entity.update_attributes(data)
          entity
        end

        def primitive?(data)
          PRIMITIVE.include? data
        end

        def error_message(e)
          message = e.response[:body].to_str rescue e.message
          JSON.parse(message).fetch('error').fetch('message') rescue message
        end

        def reset_entities
          subcaches do |subcache|
            subcache[:id].each_value { |e| e.attributes.clear } if subcache.include? :id
          end
        end

        def clear_find_cache
          subcaches do |subcache|
            subcache.delete_if { |k, v| k != :id }
          end
        end

        def subcaches
          @cache.each_value do |subcache|
            yield subcache if subcache.is_a? Hash
          end
        end

        def fetch_one(entity, id = nil)
          get("/#{entity.base_path}/#{id}")[entity.one]
        end

        def fetch_many(entity, params = {})
          get("/#{entity.base_path}/", params)[entity.many]
        end

        def cached(*keys)
          last  = keys.pop
          cache = keys.inject(@cache) { |store, key| store[key] ||= {} }
          cache[last] ||= yield
        end

        def check_ssl
          raw(:head, '/') if ssl == SSL_OPTIONS
        rescue Exception => error
          self.ssl = {} if error.class == Travis::Client::SSLError
        end
    end
  end
end
