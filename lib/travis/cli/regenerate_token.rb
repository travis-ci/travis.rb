require 'travis/cli'

module Travis
  module CLI
    class RegenerateToken < ApiCommand
      description "regenerates the stored API token"

      def run
        token = session.regenerate_token['token']
        endpoint_config['access_token'] = token
        success("Successfully regenerated the token!")
      end
    end
  end
end
