require 'travis/cli'

module Travis
  module CLI
    class Whoami < ApiCommand
      def run
        authenticate
      end
    end
  end
end
