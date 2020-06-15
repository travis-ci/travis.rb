require 'travis/client'

module Travis
  module Client
    class Error < StandardError
    end

    class SSLError < Error
    end

    class NotFound < Error
    end

    class NotLoggedIn < Error
    end

    class InvalidTokenError < Error
    end

    class GitHubLoginFailed < Error
    end

    class RepositoryMigrated < Error
    end

    class AssetNotFound < Error
      def initialize(file, *args)
        if md = file.match(%r[init/(?<lang>[^\.]+)\.yml$])
          super "unknown language #{md[:lang]}", *args
        else
          super file, *args
        end
      end
    end

    class ValidationFailed < Error
      attr_reader :errors

      def initialize(message = nil, *args)
        message = parse_message(message) if message
        super(message, *args)
      end

      def parse_message(message)
        response   = JSON.load(message)
        message    = response['message'].to_s
        if @errors = response['errors'] and @errors.any?
          readable = @errors.map { |e| "#{e['field']}: #{e['code'].gsub('_', ' ')}" }
          message += " (#{readable.join(', ')})"
        end
        message
      rescue JSON::ParserError
        message
      end
    end
  end
end
