require 'travis/cli'

module Travis
  module CLI
    class Whoami < ApiCommand
      description "outputs the current user"

      def run
        authenticate
        name = " (#{user.name})" unless user.name.to_s.empty?
        say user.login, "You are %s" << name.to_s
      end
    end
  end
end
