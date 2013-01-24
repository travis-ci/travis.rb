require 'travis/cli'

module Travis
  module CLI
    class Token < ApiCommand
      def run
        error "not logged in, please run #{command("login#{endpoint_option}")}" if access_token.nil?
        say access_token, "Your access token is %s"
      end
    end
  end
end
