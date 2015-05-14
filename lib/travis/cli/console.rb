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
        return unless pry_installed?

        Object.send(:include, Client::Namespace.new(session))
        hooks = defined?(Pry::Hooks) ? Pry::Hooks.new : {}
        binding.pry(:quiet => true, :prompt => Pry::SIMPLE_PROMPT, :output => $stdout, :hooks => hooks)
      end

      private

      def pry_installed?
        require 'pry'
        true
      rescue LoadError
        $stderr.puts 'You need to install pry to use Travis CLI console.'
        false
      end
    end
  end
end
