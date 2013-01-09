require 'travis/client/methods'
require 'faraday'
require 'faraday_middleware'
require 'json'

module Travis
  module Client
    class Session
      include Methods
      attr_reader :connection, :headers, :access_token

      def initialize(options = {})
        @headers = {}
        @cache   = {}

        options = { :uri => options } unless options.respond_to? :each_pair
        options.each_pair { |key, value| public_send("#{key}=", value) }

        raise ArgumentError, "neither :uri nor :connection specified" unless connection
        headers['Accept'] ||= 'application/vnd.travis-ci.2+json, */*; q=0.01'
      end

      def uri
        connection.url_prefix.to_s if connection
      end

      def uri=(uri)
        clear_cache!
        self.connection = Faraday.new(:url => uri) do |faraday|
          faraday.request   :json
          faraday.response  :json, :content_type => /\bjson$/
          faraday.response  :follow_redirects
          faraday.response  :raise_error
          faraday.adapter   Faraday.default_adapter
        end
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
        @connection = connection
        @headers    = connection.headers
      end

      def headers=(headers)
        clear_cache!
        connection.headers = headers if connection
        @headers = headers
      end

      def find_one(entity, id = nil)
        return create_entity(entity, "id" => id) if id.is_a? Integer
        cached(entity, :by, id) { fetch_one(entity, id) }
      end

      def find_many(entity, args = {})
        cached(entity, :many, args) { fetch_many(entity, args) }
      end

      def find_one_or_many(entity, args = nil)
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

      def reload(entity)
        result = fetch_one(entity.class, entity.id)
        entity.update_attributes(result.attributes) if result.attributes != entity.attributes
        result
      end

      def get(*args)
        result = {}
        get_raw(*args).each do |key, value|
          type = Entity.subclass_for(key)
          if value.respond_to? :to_ary
            result[key] = value.to_ary.map { |e| create_entity(type, e) }
          else
            result[key] = create_entity(type, value)
          end
        end
        result
      end

      def get_raw(*args)
        connection.get(*args).body
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

      def create_entity(type, data)
        id     = Integer(data.fetch('id'))
        entity = cached(type, :id, id) { type.new(self, id) }
        entity.update_attributes(data)
        entity
      end

      def session
        self
      end

      private

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
