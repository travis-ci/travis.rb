require 'travis/cli'

module Travis
  module CLI
    class Whoami < ApiCommand
      description "outputs the current user"

      def run
        authenticate
        say user.login, "You are %s (#{user.name})"
      end
    end
  end
end
