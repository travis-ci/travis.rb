require 'travis/cli'

module Travis
  module CLI
    class Logout < ApiCommand
      description "deletes the stored API token"

      def run
        endpoint_config.delete('access_token')
        success("Successfully logged out!")
      end
    end
  end
end
