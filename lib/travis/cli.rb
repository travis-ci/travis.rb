require 'travis/client'

module Travis
  module CLI
    autoload :ApiCommand,   'travis/cli/api_command'
    autoload :Command,      'travis/cli/command'
    autoload :Endpoint,     'travis/cli/endpoint'
    autoload :Help,         'travis/cli/help'
    autoload :Parser,       'travis/cli/parser'
    autoload :RepoCommand,  'travis/cli/repo_command'
    autoload :Whoami,       'travis/cli/whoami'

    extend self

    def run(*args)
      args, opts = preparse(args)
      name       = args.shift unless args.empty?
      command    = command(name).new(opts)
      command.parse(args)
      command.execute
    end

    def command(name)
      const_name = command_name(name)
      constant   = CLI.const_get(const_name) if const_defined? const_name
      if command? constant
        constant
      else
        $stderr.puts "unknown command #{name}"
        exit 1
      end
    end

    def commands
      CLI.constants.map { |n| CLI.const_get(n) }.select { |c| command? c }
    end

    private

      def command?(constant)
        constant and constant < Command and not constant.abstract?
      end

      def command_name(name)
        case name
        when nil, '-h', '-?' then 'Help'
        when /^--/           then command_name(name[2..-1])
        else name.to_s.capitalize
        end
      end

      # can't use flatten as it will flatten hashes
      def preparse(unparsed, args = [], opts = {})
        case unparsed
        when Hash  then opts.merge! unparsed
        when Array then unparsed.each { |e| preparse(e, args, opts) }
        else args << unparsed.to_s
        end
        [args, opts]
      end
  end
end
