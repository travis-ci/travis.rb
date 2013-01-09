require 'travis/cli'

module Travis
  module CLI
    class Whoami < ApiCommand
      def run
        authenticate
        puts user.login
      end
    end
  end
end
