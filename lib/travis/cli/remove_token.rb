require 'travis/cli'

module Travis
  module CLI
    class RemoveToken < ApiCommand
      description "deletes the stored API token"

      def run
        session.remove_token
        endpoint_config['access_token'] = nil
        success("Successfully removed the access token!")
      end
    end
  end
end
