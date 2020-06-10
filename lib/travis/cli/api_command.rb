require 'travis/cli'
require 'travis/tools/github'

module Travis
  module CLI
    class ApiCommand < Command
      include Travis::Client::Methods
      attr_accessor :enterprise_name
      attr_reader :session
      abstract

      on('-e', '--api-endpoint URL', 'Travis API server to talk to')
      on('-I', '--[no-]insecure', 'do not verify SSL certificate of API endpoint')
      on('--pro', "short-cut for --api-endpoint '#{Travis::Client::COM_URI}'") { |c,_| c.api_endpoint = Travis::Client::COM_URI }
      on('--com', "short-cut for --api-endpoint '#{Travis::Client::COM_URI}'") { |c,_| c.api_endpoint = Travis::Client::COM_URI }
      on('--org', "short-cut for --api-endpoint '#{Travis::Client::ORG_URI}'") { |c,_| c.api_endpoint = Travis::Client::ORG_URI }
      on('--staging', 'talks to staging system') { |c,_| c.api_endpoint = c.api_endpoint.gsub(/api/, 'api-staging') }
      on('-t', '--token [ACCESS_TOKEN]', 'access token to use') { |c, t| c.access_token = t }

      on('--debug', 'show API requests') do |c,_|
        c.debug = true
        c.session.instrument do |info, request|
          c.time(info, request)
        end
      end

      on('--debug-http', 'show HTTP(S) exchange') do |c,_|
        c.session.debug_http = true
      end

      on('-X', '--enterprise [NAME]', 'use enterprise setup (optionally takes name for multiple setups)') do |c, name|
        c.enterprise_name = name || 'default'
      end

      on('--adapter ADAPTER', 'Faraday adapter to use for HTTP requests. If omitted, use Typhoeus if it is installed, ' \
        'and Net::HTTP otherwise. See https://lostisland.github.io/faraday/adapters/ for more info') do |c, adapter|
        begin
          adapter.gsub! '-', '_'
          require "faraday/adapter/#{adapter}"
          require 'typhoeus/adapters/faraday' if adapter == 'typhoeus'
          c.session.faraday_adapter = adapter.to_sym
        rescue LoadError => e
          warn "\`--adapter #{adapter}\` is given, but it is not installed. Run \`gem install #{adapter}\` and try again"
          exit 1
        end
      end

      def initialize(*)
        @session = Travis::Client.new(:agent_info => "command #{command_name}")
        super
      end

      def endpoint_config
        config['endpoints'] ||= {}
        config['endpoints'][api_endpoint] ||= {}
      end

      def setup
        setup_enterprise
        self.api_endpoint = default_endpoint if default_endpoint and not explicit_api_endpoint?
        self.access_token               ||= fetch_token
        endpoint_config['access_token'] ||= access_token
        endpoint_config['insecure']       = insecure unless insecure.nil?
        self.insecure                     = endpoint_config['insecure']
        session.ssl                       = { :verify => false } if insecure?
        authenticate if pro? or enterprise?
      end

      def enterprise?
        !!endpoint_config['enterprise']
      end

      def pro?
        api_endpoint == Travis::Client::COM_URI
      end

      def org?
        api_endpoint == Travis::Client::ORG_URI
      end

      def detected_endpoint?
        api_endpoint == detected_endpoint
      end

      def authenticate
        error "not logged in, please run #{command("login#{endpoint_option}")}" if access_token.nil?
      end

      def sync(block = true, dot = '.')
        user.sync

        steps = count = 1
        while block and user.reload.syncing?
          count += 1
          sleep(1)

          if count % steps == 0
            steps = count/10 + 1
            output.print dot
          end
        end
      end

      private

        def setup_enterprise
          return unless setup_enterprise?
          c = config['enterprise'] ||= {}
          c[enterprise_name] = api_endpoint if explicit_api_endpoint?
          c[enterprise_name] ||= write_to($stderr) do
            error "enterprise setup not configured" unless interactive?
            user_input                  = ask(color("Enterprise domain: ", :bold)).to_s
            domain                      = user_input[%r{^(?:https?://)?(.*?)/?(?:/api/?)?$}, 1]
            endpoint                    = "https://#{domain}/api"
            config['default_endpoint']  = endpoint if agree("Use #{color domain, :bold} as default endpoint? ") { |q| q.default = 'yes' }
            endpoint
          end
          self.api_endpoint             = c[enterprise_name]
          self.insecure                 = insecure unless insecure.nil?
          self.session.ssl.delete :ca_file
          endpoint_config['enterprise'] = true
          @setup_ennterpise             = true
        end

        def setup_enterprise?
          @setup_ennterpise ||= false
          !!enterprise_name and not @setup_ennterpise
        end

        def load_gh

          gh_config       = session.config['github']
          gh_config     &&= gh_config.inject({}) { |h,(k,v)| h.update(k.to_sym => v) }
          gh_config     ||= {}
          gh_config[:ssl] = Travis::Client::Session::SSL_OPTIONS
          gh_config[:ssl] = { :verify => false } if gh_config[:api_url] and gh_config[:api_url] != "https://api.github.com"
          gh_config.delete :scopes

          gh_config[:instrumenter] = proc do |type, payload, &block|
            next block.call unless type == 'http.gh'
            time("GitHub API: #{payload[:verb].to_s.upcase} #{payload[:url]}", block)
          end if debug?

          GH.set(gh_config)
        end

        def github_endpoint
          load_gh
          GH.with({}).api_host
        end

        def listen(*args)
          super(*args) do |listener|
            on_signal { listener.disconnect }
            yield listener
          end
        end

        def default_endpoint
          ENV['TRAVIS_ENDPOINT'] || config['default_endpoint']
        end

        def detected_endpoint
          default_endpoint || Travis::Client::ORG_URI
        end

        def endpoint_option
          return ""       if org? and detected_endpoint?
          return " --org" if org?
          return " --pro" if pro?

          if config['enterprise']
            key, _ = config['enterprise'].detect { |k,v| v.start_with? api_endpoint }
            return " -X"        if key == "default"
            return " -X #{key}" if key
          end

          " -e %p" % api_endpoint
        end

        def fetch_token
          ENV['TRAVIS_TOKEN'] || endpoint_config['access_token']
        end
    end
  end
end
