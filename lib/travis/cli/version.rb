require 'travis/cli'
require 'travis/version'

module Travis
  module CLI
    class Version < Command
      description "outputs the client version"

      def run
        say Travis::VERSION
      end

      def check_version
      end
    end
  end
end
