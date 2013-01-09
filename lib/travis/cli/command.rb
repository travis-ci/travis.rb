require 'travis/cli'

module Travis
  module CLI
    class Command
      extend Parser

      on('-h', '--help', 'Display help') do |c|
        puts c.help
        exit
      end

      def self.command_name
        name[/[^:]*$/].downcase
      end

      @@abstract ||= [Command] # ignore the man behind the courtains!
      def self.abstract?
        @@abstract.include? self
      end

      def self.abstract
        @@abstract << self
      end

      attr_accessor :arguments

      def initialize(options = {})
        options.each do |key, value|
          public_send("#{key}=", value) if respond_to? "#{key}="
        end
        @arguments ||= []
      end

      def parse(args)
        rest = parser.parse(args)
        arguments.concat(rest)
      rescue OptionParser::InvalidOption => e
        $stderr.puts e.message
        exit 1
      end

      def setup
      end

      def execute
        check_arity(method(:run), *arguments)
        setup
        run(*arguments)
      end

      def command_name
        self.class.command_name
      end

      def usage
        usage  = "Usage: #$0 #{command_name} [options]"
        method = method(:run)
        if method.respond_to? :parameters
          method.parameters.each do |type, name|
            name = "[#{name}]"      if type == :opt
            name = "[#{name}..]" if type == :rest
            usage << " #{name}"
          end
        else
          usage << " ..."
        end
        usage
      end

      def help
        parser.banner = usage
        parser.to_s
      end

      private

        def check_arity(method, *args)
          return unless method.respond_to? :parameters
          method.parameters.each do |type, name|
            return if type == :rest
            wrong_args("few") unless args.shift or type == :opt
          end
          wrong_args("many") if args.any?
        end

        def wrong_args(quantity)
          $stderr.puts "too #{quantity} arguments"
          $stderr.puts help
          exit 1
        end
    end
  end
end
