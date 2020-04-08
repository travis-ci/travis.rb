require 'travis/cli'

module Travis
  module CLI
    class Console < ApiCommand
      description "interactive shell; requires `pry`"
      on '-x', '--eval LINE', 'run line of ruby' do |c, line|
        c.instance_eval(line)
        exit
      end

      def run
        ensure_pry

        Object.send(:include, Client::Namespace.new(session))
        hooks = defined?(Pry::Hooks) ? Pry::Hooks.new : {}
        opts = {quiet: true, output: $stdout, hooks: hooks }
        opts.merge!({prompt: prompt}) if prompt
        binding.pry(opts)
      end

      private

      def ensure_pry
        require 'pry'
      rescue LoadError
        msg = [
          'You need to install pry to use Travis CLI console. Try',
          nil,
          '$ (sudo) gem install pry'
        ].join("\n")
        error msg
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
