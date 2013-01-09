require 'travis/cli'

module Travis
  module CLI
    class ApiCommand < Command
      include Travis::Client::Methods
      attr_reader :session
      abstract

      on('-e', '--api-endpoint URL', 'Travis API server to talk to')
      on('--pro', "short-cut for --api-endpoint '#{Travis::Client::PRO_URI}'") { |c| c.api_endpoint = Travis::Client::PRO_URI }
      on('--org', "short-cut for --api-endpoint '#{Travis::Client::ORG_URI}'") { |c| c.api_endpoint = Travis::Client::ORG_URI }
      on('-t', '--token [ACCESS_TOKEN]', 'access token to use') { |c, t| c.access_token = t }

      def initialize(*)
        @session = Travis::Client.new
        super
      end

      def endpoint_config
        config['endpoints'] ||= {}
        config['endpoints'][api_endpoint] ||= {}
      end

      def setup
        self.access_token ||= endpoint_config['access_token']
        authenticate if api_endpoint.start_with? Travis::Client::PRO_URI
        endpoint_config['access_token'] ||= access_token
      end

      def authenticate
        return if access_token
        fail "authentication failed"
      end
    end
  end
end
