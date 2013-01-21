require 'travis/cli'

module Travis
  module CLI
    class ApiCommand < Command
      include Travis::Client::Methods
      attr_reader :session
      abstract

      on('-e', '--api-endpoint URL', 'Travis API server to talk to')
      on('--pro', "short-cut for --api-endpoint '#{Travis::Client::PRO_URI}'") { |c,_| c.api_endpoint = Travis::Client::PRO_URI }
      on('--org', "short-cut for --api-endpoint '#{Travis::Client::ORG_URI}'") { |c,_| c.api_endpoint = Travis::Client::ORG_URI }
      on('-t', '--token [ACCESS_TOKEN]', 'access token to use') { |c, t| c.access_token = t }

      on('--debug', 'show API requests') do |c,_|
        c.session.instrument do |info, request|
          c.debug(info)
          request.call
        end
      end

      def initialize(*)
        @session = Travis::Client.new
        super
      end

      def endpoint_config
        config['endpoints'] ||= {}
        config['endpoints'][api_endpoint] ||= {}
      end

      def setup
        self.access_token               ||= fetch_token
        endpoint_config['access_token'] ||= access_token
        authenticate if pro?
      end

      def pro?
        api_endpoint == Travis::Client::PRO_URI
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

        def detected_endpoint
          Travis::Client::ORG_URI
        end

        def endpoint_option
          return ""       if org? and detected_endpoint?
          return " --org" if org?
          return " --pro" if pro?
          " -e %p" % api_endpoint
        end

        def fetch_token
          return endpoint_config['access_token'] if endpoint_config['access_token']
        end
    end
  end
end
