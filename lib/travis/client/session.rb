require 'travis/client'

require 'faraday'
require 'faraday_middleware'
require 'travis/tools/system'

begin
  require 'typhoeus/adapters/faraday' unless Travis::Tools::System.windows?
rescue LoadError
end

require 'json'

module Travis
  module Client
    class Session
      SSL_OPTIONS = { :ca_file => File.expand_path("../../cacert.pem", __FILE__) }
      include Methods
      attr_reader :connection, :headers, :access_token, :instruments, :faraday_adapter

      def initialize(options = Travis::Client::ORG_URI)
        @headers         = {}
        @cache           = {}
        @instruments     = []
        @config          = nil
        @faraday_adapter = defined?(Typhoeus) ? :typhoeus : :net_http

        options = { :uri => options } unless options.respond_to? :each_pair
        options.each_pair { |key, value| public_send("#{key}=", value) }

        raise ArgumentError, "neither :uri nor :connection specified" unless connection
        headers['Accept'] ||= 'application/json; version=2'
      end

      def uri
        connection.url_prefix.to_s if connection
      end

      def uri=(uri)
        clear_cache!
        self.connection = Faraday.new(:url => uri, :ssl => SSL_OPTIONS) do |faraday|
          faraday.request  :url_encoded
          faraday.response :json
          faraday.response :follow_redirects
          faraday.response :raise_error
          faraday.adapter(*faraday_adapter)
        end
      end

      def faraday_adapter=(adapter)
        @faraday_adapter = adapter
        self.uri &&= uri
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
        raise Travis::Error, "cannot fetch #{entity}" unless entity.respond_to?(:many) and entity.many
        return create_entity(entity, "id" => id) if id.is_a? Integer
        cached(entity, :by, id) { fetch_one(entity, id) }
      end

      def find_many(entity, args = {})
        raise Travis::Error, "cannot fetch #{entity}" unless entity.respond_to?(:many) and entity.many
        cached(entity, :many, args) { fetch_many(entity, args) }
      end

      def find_one_or_many(entity, args = nil)
        raise Travis::Error, "cannot fetch #{entity}" unless entity.respond_to?(:many) and entity.many
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
        @config ||= get_raw('/config')['config']
      end

      def load(data)
        result = {}
        (data || {}).each_pair do |key, value|
          type = Entity.subclass_for(key)
          if value.respond_to? :to_ary
            result[key] = value.to_ary.map { |e| create_entity(type, e) }
          else
            result[key] = create_entity(type, value)
          end
        end
        result
      end

      def get(*args)
        load get_raw(*args)
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

      def raw(verb, *args)
        instrumented(verb.to_s.upcase, *args) { connection.public_send(verb, *args).body }
      rescue Faraday::Error::ClientError => e
        handle_error(e)
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
        access_token and user.channels != ['common']
      end

      private

        def instrumented(name, *args)
          name   = [name, *args.map(&:inspect)].join(" ") if args.any?
          result = nil
          chain  = instruments + [proc { |n,l| result = yield }]
          lift   = proc { chain.shift.call(name, lift) }
          lift.call
          result
        end

        def create_entity(type, data)
          data   = { "id" => data } if Integer === data or String === data
          id     = type.cast_id(data.fetch('id'))
          entity = cached(type, :id, id) { type.new(self, id) }
          entity.update_attributes(data)
          entity
        end

        def handle_error(e)
          klass   = Travis::Client::NotFound if e.is_a? Faraday::Error::ResourceNotFound
          klass ||= Travis::Client::Error
          raise klass, error_message(e), e.backtrace
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
          get("/#{entity.many}/#{id}")[entity.one]
        end

        def fetch_many(entity, params = {})
          get("/#{entity.many}/", params)[entity.many]
        end

        def cached(*keys)
          last  = keys.pop
          cache = keys.inject(@cache) { |store, key| store[key] ||= {} }
          cache[last] ||= yield
        end
    end
  end
end
