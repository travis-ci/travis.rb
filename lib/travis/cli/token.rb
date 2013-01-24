require 'travis/cli'

module Travis
  module CLI
    class Token < ApiCommand
      def run
        if access_token.nil?
          error "not logged in, please run #{command("login#{endpoint_option}")}"
        else
          say "Your access token is #{access_token}"
        end
      end
    end
  end
end
