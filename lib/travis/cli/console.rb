require 'travis/cli'

module Travis
  module CLI
    class Console < ApiCommand
      description "interactive shell"
      on '-x', '--eval LINE', 'run line of ruby' do |c, line|
        c.instance_eval(line)
        exit
      end

      def run
        Travis::CLI.silent { require 'pry' }
        Object.send(:include, Client::Namespace.new(session))
        binding.pry(:quiet => true, :prompt => Pry::SIMPLE_PROMPT, :output => $stdout)
      end
    end
  end
end
