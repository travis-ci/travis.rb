require 'travis/cli'

module Travis
  module CLI
    class Console < ApiCommand
      description "interactive shell"

      def run
        Travis::CLI.silent { require 'pry' }
        Object.send(:include, Client::Namespace.new(session))
        binding.pry(:quiet => true, :prompt => Pry::SIMPLE_PROMPT, :output => $stdout)
      end
    end
  end
end
