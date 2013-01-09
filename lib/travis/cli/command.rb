require 'travis/cli'
require 'yaml'

module Travis
  module CLI
    class Command
      extend Parser

      on('-h', '--help', 'Display help') do |c|
        puts c.help
        exit
      end

       on('-E', '--[no-]explode', "don't rescue exceptions")

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

      attr_accessor :arguments, :config

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
        load_config
        setup
        run(*arguments)
        store_config
      rescue Exception => e
        raise(e) if explode?
        $stderr.puts e.message
        exit 1
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

        def asset_path(name)
          path = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', Dir.home) }
          Dir.mkdir(path, 0700) unless File.directory? path
          File.join(path, name)
        end

        def load_asset(name, default = nil)
          path = asset_path(name)
          File.exist?(path) ? File.read(path) : default
        end

        def save_asset(name, content)
          File.write(asset_path(name), content.to_s)
        end

        def load_config
          @config = YAML.load load_asset('config.yml', '{}')
          @original_config = @config.dup
        end

        def store_config
          return if @original_config == @config
          save_asset('config.yml', @config.to_yaml)
        end

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
