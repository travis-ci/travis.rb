require 'travis/cli'

module Travis
  module CLI
    class Endpoint < ApiCommand
      def run
        puts api_endpoint
      end
    end
  end
end
