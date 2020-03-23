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
        opts = {quiet: true, output: $stdout, hooks: hooks }
        opts.merge!({prompt: prompt}) if prompt
        binding.pry(opts)
      end

      private

      def pry_installed?
        require 'pry'
        true
      rescue LoadError
        $stderr.puts 'You need to install pry to use Travis CLI console. Try'
        $stderr.puts
        $stderr.puts '$ (sudo) gem install pry'
        false
      end

      def prompt
        if Pry.const_defined? :SIMPLE_PROMPT
          Pry::SIMPLE_PROMPT
        elsif defined?(Pry::Prompt)
          Pry::Prompt[:simple]
        else
          nil
        end
      end
    end
  end
end
