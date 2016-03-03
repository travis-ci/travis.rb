require 'travis/cli'
require 'travis/tools/system'
require 'travis/tools/formatter'
require 'travis/tools/assets'
require 'travis/tools/completion'
require 'travis/version'

require 'highline'
require 'forwardable'
require 'yaml'
require 'timeout'

module Travis
  module CLI
    class Command
      MINUTE = 60
      HOUR   = 3600
      DAY    = 86400
      WEEK   = 604800

      include Tools::Assets
      extend Parser, Forwardable, Tools::Assets
      def_delegators :terminal, :agree, :ask, :choose

      HighLine.use_color = Tools::System.unix? && $stdout.tty?
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
        HighLine.use_color = v if Tools::System.unix?
        c.force_interactive = v
      end

      on('-E', '--[no-]explode', "don't rescue exceptions")
      on('--skip-version-check', "don't check if travis client is up to date")
      on('--skip-completion-check', "don't check if auto-completion is set up")

      def self.command_name
        name[/[^:]*$/].split(/(?=[A-Z])/).map(&:downcase).join('-')
      end

      @@abstract ||= [Command] # ignore the man behind the courtains!
      def self.abstract?
        @@abstract.include? self
      end

      def self.abstract
        @@abstract << self
      end

      def self.skip(*names)
        names.each { |n| define_method(n) {} }
      end

      def self.description(description = nil)
        @description = description if description
        @description ||= ""
      end

      def self.subcommands(*list)
        return @subcommands ||= [] if list.empty?
        @subcommands = list

        define_method :run do |subcommand, *args|
          error "Unknown subcommand. Available: #{list.join(', ')}." unless list.include? subcommand.to_sym
          send(subcommand, *args)
        end

        define_method :usage do
          usages = list.map { |c| color(usage_for("#{command_name} #{c}", c), :command) }
          "\nUsage: #{usages.join("\n       ")}\n\n"
        end
      end

      attr_accessor :arguments, :config, :force_interactive, :formatter, :debug
      attr_reader :input, :output
      alias_method :debug?, :debug

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
        seconds_since = Time.now.to_i - last_check['at'].to_i

        return if skip_version_check?
        return if seconds_since < MINUTE

        case seconds_since
        when MINUTE .. HOUR then timeout = 0.5
        when HOUR   .. DAY  then timeout = 1.0
        when DAY    .. WEEK then timeout = 2.0
        else                     timeout = 10.0
        end

        Timeout.timeout(timeout) do
          response              = Faraday.get('https://rubygems.org/api/v1/gems/travis.json', {}, 'If-None-Match' => last_check['etag'].to_s)
          last_check['etag']    = response.headers['etag']
          last_check['version'] = JSON.parse(response.body)['version'] if response.status == 200
        end

        last_check['at'] = Time.now.to_i
        unless Tools::System.recent_version? Travis::VERSION, last_check['version']
          warn "Outdated CLI version, run `gem install travis`."
        end
      rescue Timeout::Error, Faraday::Error::ClientError => error
        debug "#{error.class}: #{error.message}"
      end

      def check_completion
        return if skip_completion_check? or !interactive?

        if config['checked_completion']
          Tools::Completion.update_completion if config['completion_version'] != Travis::VERSION
        else
          write_to($stderr) do
            next Tools::Completion.update_completion if Tools::Completion.completion_installed?
            next unless agree('Shell completion not installed. Would you like to install it now? ') { |q| q.default = "y" }
            Tools::Completion.install_completion
          end
        end

        config['checked_completion'] = true
        config['completion_version'] = Travis::VERSION
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
        check_completion
        setup
        run(*arguments)
        clear_error
        store_config
      rescue Travis::Client::NotLoggedIn => e
        raise(e) if explode?
        error "#{e.message} - try running #{command("login#{endpoint_option}")}"
      rescue Travis::Client::NotFound => e
        raise(e) if explode?
        error "resource not found (#{e.message})"
      rescue Travis::Client::Error => e
        raise(e) if explode?
        error e.message
      rescue StandardError => e
        raise(e) if explode?
        message = e.message
        message += color("\nfor a full error report, run #{command("report#{endpoint_option}")}", :error) if interactive?
        store_error(e)
        error(message)
      end

      def command_name
        self.class.command_name
      end

      def usage
        "Usage: " << color(usage_for(command_name, :run), :command)
      end

      def usage_for(prefix, method)
        usage = "travis #{prefix}"
        method = method(method)
        if method.respond_to? :parameters
          method.parameters.each do |type, name|
            name = name.upcase
            name = "[#{name}]"   if type == :opt
            name = "[#{name}..]" if type == :rest
            usage << " #{name}"
          end
        elsif method.arity != 0
          usage << " ..."
        end
        usage << " [OPTIONS]"
      end

      def help(info = "")
        parser.banner = usage
        self.class.description.sub(/./) { |c| c.upcase } + ".\n" + info + parser.to_s
      end

      def say(data, format = nil, style = nil)
        terminal.say format(data, format, style)
      end

      def debug(line)
        return unless debug?
        write_to($stderr) do
          say color("** #{line}", :debug)
        end
      end

      def time(info, callback = Proc.new)
        return callback.call unless debug?
        start = Time.now
        debug(info)
        callback.call
        duration = Time.now - start
        debug("  took %.2g seconds" % duration)
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

        def store_error(exception)
          message = "An error occurred running `travis %s%s`:\n    %p: %s\n" % [command_name, endpoint_option, exception.class, exception.message]
          exception.backtrace.each { |l| message << "        from #{l}\n" }
          save_file("error.log", message)
        end

        def clear_error
          delete_file("error.log")
        end

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
          terminal.color(line || '???', Array(style).map(&:to_sym))
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
          color("#{File.basename($0)} #{name}", :command)
        end

        def success(line)
          say color(line, :success) if interactive?
        end

        def config_path(name)
          path = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', Dir.home) }
          Dir.mkdir(path, 0700) unless File.directory? path
          File.join(path, name)
        end

        def load_file(name, default = nil)
          return default unless path = config_path(name) and File.exist? path
          debug "Loading %p" % path
          File.read(path)
        end

        def delete_file(name)
          return unless path = config_path(name) and File.exist? path
          debug "Deleting %p" % path
          File.delete(path)
        end

        def save_file(name, content, read_only = false)
          path = config_path(name)
          debug "Storing %p" % path
          File.open(path, 'w') do |file|
            file.write(content.to_s)
            file.chmod(0600) if read_only
          end
        end

        YAML_ERROR = defined?(Psych::SyntaxError) ? Psych::SyntaxError : ArgumentError
        def load_config
          @config          = YAML.load load_file('config.yml', '{}')
          @config        ||= {}
          @original_config = @config.dup
        rescue YAML_ERROR => error
          raise error if explode?
          warn "Broken config file: #{color config_path('config.yml'), :bold}"
          exit 1 unless interactive? and agree("Remove config file? ") { |q| q.default = "no" }
          @original_config, @config = {}, {}
        end

        def store_config
          save_file('config.yml', @config.to_yaml, true)
        end

        def check_arity(method, *args)
          return unless method.respond_to? :parameters
          method.parameters.each do |type, name|
            return if type == :rest
            wrong_args("few") unless args.shift or type == :opt or type == :block
          end
          wrong_args("many") if args.any?
        end

        def danger_zone?(message)
          agree(color("DANGER ZONE: ", [:red, :bold]) << message << " ") { |q| q.default = "no" }
        end

        def write_file(file, content, force = false)
          error "#{file} already exists" unless write_file?(file, force)
          File.write(file, content)
        end

        def write_file?(file, force)
          return true if force or not File.exist?(file)
          return false unless interactive?
          danger_zone? "Override existing #{color(file, :info)}?"
        end

        def wrong_args(quantity)
          error "too #{quantity} arguments" do
            say help
          end
        end

        def endpoint_option
          ""
        end
    end
  end
end
