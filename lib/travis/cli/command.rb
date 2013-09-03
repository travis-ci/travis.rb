require 'travis/cli'
require 'travis/tools/system'
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

      HighLine.use_color = !Tools::System.windows? && $stdout.tty?
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
        HighLine.use_color = v unless Tools::System.windows?
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

      def self.description(description = nil)
        @description = description if description
        @description ||= ""
      end

      attr_accessor :arguments, :config, :force_interactive, :formatter
      attr_reader :input, :output

      def initialize(options = {})
        @on_signal  = []
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

      def last_check
        config['last_check'] ||= {
          # migrate from old values
          'at'   => config.delete('last_version_check'),
          'etag' => config.delete('etag')
        }
      end

      def check_version
        last_check.clear if last_check['version'] != Travis::VERSION

        return if skip_version_check?
        return if Time.now.to_i - last_check['at'].to_i < 3600

        Timeout.timeout 1.0 do
          response              = Faraday.get('https://rubygems.org/api/v1/gems/travis.json', {}, 'If-None-Match' => last_check['etag'].to_s)
          last_check['etag']    = response.headers['etag']
          last_check['version'] = JSON.parse(response.body)['version'] if response.status == 200
        end

        last_check['at'] = Time.now.to_i
        error "Outdated CLI version, run `gem install travis` or use --skip-version-check." if Travis::VERSION < last_check['version']
      rescue Timeout::Error, Faraday::Error::ClientError
      end

      def check_ruby
        return if RUBY_VERSION > '1.9.2' or skip_version_check?
        warn "Your Ruby version is outdated, please consider upgrading, as we will drop support for #{RUBY_VERSION} soon!"
      end

      def execute
        setup_trap
        check_ruby
        check_arity(method(:run), *arguments)
        load_config
        check_version
        setup
        run(*arguments)
        store_config
      rescue StandardError => e
        raise(e) if explode?
        message = e.message
        message += " - need to run `travis login` again?" if Travis::Client::Error === e and message == 'access denied'
        error message
      end

      def command_name
        self.class.command_name
      end

      def usage
        usage  = "travis #{command_name}"
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

      def help(info = "")
        parser.banner = usage
        self.class.description.sub(/./) { |c| c.upcase } + ".\n" + info + parser.to_s
      end

      def say(data, format = nil, style = nil)
        terminal.say format(data, format, style)
      end

      def debug(line)
        write_to($stderr) do
          say color("** #{line}", :debug)
        end
      end

      def info(line)
        write_to($stderr) do
          say color(line, :info)
        end
      end

      def on_signal(&block)
        @on_signal << block
      end

      private

        def setup_trap
          [:INT, :TERM].each do |signal|
            trap signal do
              @on_signal.each { |c| c.call }
              exit 1
            end
          end
        end

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
          return line.to_s unless interactive?
          terminal.color(line.to_s, Array(style).map(&:to_sym))
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
