begin
  require 'travis/client'
rescue LoadError => e
  if e.message == 'no such file to load -- json'
    $stderr.puts "You should either run `gem install json` or upgrade your Ruby version!"
    exit 1
  else
    raise e
  end
end

require 'stringio'

module Travis
  module CLI
    autoload :Token,        'travis/cli/token'
    autoload :ApiCommand,   'travis/cli/api_command'
    autoload :Accounts,     'travis/cli/accounts'
    autoload :Branches,     'travis/cli/branches'
    autoload :Cache,        'travis/cli/cache'
    autoload :Cancel,       'travis/cli/cancel'
    autoload :Command,      'travis/cli/command'
    autoload :Console,      'travis/cli/console'
    autoload :Disable,      'travis/cli/disable'
    autoload :Enable,       'travis/cli/enable'
    autoload :Encrypt,      'travis/cli/encrypt'
    autoload :EncryptFile,  'travis/cli/encrypt_file'
    autoload :Endpoint,     'travis/cli/endpoint'
    autoload :Env,          'travis/cli/env'
    autoload :Help,         'travis/cli/help'
    autoload :History,      'travis/cli/history'
    autoload :Init,         'travis/cli/init'
    autoload :Lint,         'travis/cli/lint'
    autoload :Login,        'travis/cli/login'
    autoload :Logout,       'travis/cli/logout'
    autoload :Logs,         'travis/cli/logs'
    autoload :Monitor,      'travis/cli/monitor'
    autoload :Open,         'travis/cli/open'
    autoload :Parser,       'travis/cli/parser'
    autoload :Pubkey,       'travis/cli/pubkey'
    autoload :Raw,          'travis/cli/raw'
    autoload :RepoCommand,  'travis/cli/repo_command'
    autoload :Report,       'travis/cli/report'
    autoload :Repos,        'travis/cli/repos'
    autoload :Restart,      'travis/cli/restart'
    autoload :Requests,     'travis/cli/requests'
    autoload :Settings,     'travis/cli/settings'
    autoload :Setup,        'travis/cli/setup'
    autoload :Show,         'travis/cli/show'
    autoload :Sshkey,       'travis/cli/sshkey'
    autoload :Status,       'travis/cli/status'
    autoload :Sync,         'travis/cli/sync'
    autoload :Version,      'travis/cli/version'
    autoload :Whatsup,      'travis/cli/whatsup'
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
      constant   = CLI.const_get(const_name) if const_name =~ /^[A-Z][A-Za-z]+$/ and const_defined? const_name
      if command? constant
        constant
      else
        $stderr.puts "unknown command #{name}"
        exit 1
      end
    end

    def commands
      CLI.constants.map { |n| try_const_get(n) }.select { |c| command? c }
    end

    def silent
      stderr, $stderr = $stderr, dummy_io
      stdout, $stdout = $stdout, dummy_io
      yield
    ensure
      $stderr = stderr if stderr
      $stdout = stdout if stdout
    end

    private

      def try_const_get(name)
        CLI.const_get(name)
      rescue Exception
      end

      def dummy_io
        return StringIO.new unless defined? IO::NULL and IO::NULL
        File.open(IO::NULL, 'w')
      end

      def command?(constant)
        constant.is_a? Class and constant < Command and not constant.abstract?
      end

      def command_name(name)
        case name
        when nil, '-h', '-?' then 'Help'
        when '-v'            then 'Version'
        when /^--/           then command_name(name[2..-1])
        else name.split('-').map(&:capitalize).join
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
