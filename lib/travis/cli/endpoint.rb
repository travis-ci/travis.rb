require 'travis/cli'

module Travis
  module CLI
    class Endpoint < ApiCommand
      skip :authenticate

      def run
        say api_endpoint, "API endpoint: %s"
      end
    end
  end
end
