require 'travis/cli'

module Travis
  module CLI
    class Endpoint < ApiCommand
      def authenticate
        # skip authentication on pro
      end

      def run
        puts api_endpoint
      end
    end
  end
end
