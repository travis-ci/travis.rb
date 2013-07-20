require 'travis/cli'
require 'travis/tools/formatter'
require 'travis/version'

require 'highline'
require 'forwardable'
require 'yaml'
require 'timeout'

module Travis
  module CLI
    class Command
      extend Parser
      extend Forwardable
      def_delegators :terminal, :agree, :ask, :choose

      HighLine.use_color = !CLI.windows? && $stdout.tty?
      HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
        cs[:command]   = [ :bold             ]
        cs[:error]     = [ :red              ]
        cs[:important] = [ :bold, :underline ]
        cs[:success]   = [ :green            ]
        cs[:info]      = [ :yellow           ]
        cs[:debug]     = [ :magenta          ]
      end

      on('-h', '--help', 'Display help') do |c, _|
        c.say c.help
        exit
      end

      on('-i', '--[no-]interactive', "be interactive and colorful") do |c, v|
        HighLine.use_color = v unless CLI.windows?
        c.force_interactive = v
      end

      on('-E', '--[no-]explode', "don't rescue exceptions")
      on('--skip-version-check', "don't check if travis client is up to date")

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

      def self.skip(name)
        define_method(name) {}
      end

      attr_accessor :arguments, :config, :force_interactive, :formatter
      attr_reader :input, :output

      def initialize(options = {})
        @formatter  = Travis::Tools::Formatter.new
        self.output = $stdout
        self.input  = $stdin
        options.each do |key, value|
          public_send("#{key}=", value) if respond_to? "#{key}="
        end
        @arguments ||= []
      end

      def terminal
        @terminal ||= HighLine.new(input, output)
      end

      def input=(io)
        @terminal = nil
        @input = io
      end

      def output=(io)
        @terminal = nil
        @output = io
      end

      def write_to(io)
        io_was, self.output = output, io
        yield
      ensure
        self.output = io_was if io_was
      end

      def parse(args)
        rest = parser.parse(args)
        arguments.concat(rest)
      rescue OptionParser::ParseError => e
        error e.message
      end

      def setup
      end

      def check_version
        return if skip_version_check?
        return if Time.now.to_i - config['last_version_check'].to_i < 3600
        version = Travis::VERSION

        Timeout.timeout 1.0 do
          response       = Faraday.get('https://rubygems.org/api/v1/gems/travis.json', {}, 'If-None-Match' => config['etag'].to_s)
          config['etag'] = response.headers['etag']
          version        = JSON.parse(response.body)['version'] if response.status == 200
        end

        if Travis::VERSION >= version
          config['last_version_check'] = Time.now.to_i
        else
          error "Outdated CLI version (#{Travis::VERSION}, current is #{version}), " \
            "run `gem install travis -v #{version}` or use --skip-version-check."
        end
      rescue Timeout::Error, Faraday::Error::ClientError
      end

      def execute
        check_arity(method(:run), *arguments)
        load_config
        check_version
        setup
        run(*arguments)
        store_config
      rescue StandardError => e
        raise(e) if explode?
        error e.message
      end

      def command_name
        self.class.command_name
      end

      def usage
        usage  = "#$0 #{command_name}"
        method = method(:run)
        if method.respond_to? :parameters
          method.parameters.each do |type, name|
            name = "[#{name}]"      if type == :opt
            name = "[#{name}..]" if type == :rest
            usage << " #{name}"
          end
        elsif method.arity != 0
          usage << " ..."
        end
        usage << " [options]"
        "Usage: " << color(usage, :command)
      end

      def help
        parser.banner = usage
        parser.to_s
      end

      def say(data, format = nil, style = nil)
        terminal.say format(data, format, style)
      end

      def debug(line)
        write_to($stderr) do
          say color("** #{line}", :debug)
        end
      end

      private

        def format(data, format = nil, style = nil)
          style ||= :important
          data = format % color(data, style) if format and interactive?
          data = data.gsub(/<\[\[/, '<%=').gsub(/\]\]>/, '%>')
          data.encode! 'utf-8' if data.respond_to? :encode!
          data
        end

        def template(*args)
          File.read(*args).split('__END__', 2)[1].strip
        end

        def color(line, style)
          return line unless interactive?
          terminal.color(line, Array(style).map(&:to_sym))
        end

        def interactive?(io = output)
          return io.tty? if force_interactive.nil?
          force_interactive
        end

        def empty_line
          say "\n"
        end

        def warn(message)
          write_to($stderr) do
            say color(message, :error)
            yield if block_given?
          end
        end

        def error(message, &block)
          warn(message, &block)
          exit 1
        end

        def command(name)
          color("#$0 #{name}", :command)
        end

        def success(line)
          say color(line, :success) if interactive?
        end

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
          save_asset('config.yml', @config.to_yaml)
        end

        def check_arity(method, *args)
          return unless method.respond_to? :parameters
          method.parameters.each do |type, name|
            return if type == :rest
            wrong_args("few") unless args.shift or type == :opt or type == :block
          end
          wrong_args("many") if args.any?
        end

        def wrong_args(quantity)
          error "too #{quantity} arguments" do
            say help
          end
        end
    end
  end
end
