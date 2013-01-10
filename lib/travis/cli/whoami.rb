require 'travis/cli'

module Travis
  module CLI
    class Whoami < ApiCommand
      def run
        authenticate
        say user.login, "You are %s (#{user.name})"
      end
    end
  end
end
