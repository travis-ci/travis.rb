require 'travis/cli'

module Travis
  module CLI
    class Logout < ApiCommand
      def run
        endpoint_config.delete('access_token')
        success("Successfully logged out!")
      end
    end
  end
end
