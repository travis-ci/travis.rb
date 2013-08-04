require 'travis/cli'

module Travis
  module CLI
    class Token < ApiCommand
      def run
        authenticate
        say access_token, "Your access token is %s"
      end
    end
  end
end
