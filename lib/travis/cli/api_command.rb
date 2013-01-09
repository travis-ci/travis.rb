require 'travis/cli'

module Travis
  module CLI
    class ApiCommand < Command
      attr_accessor :client
      abstract

      on('-e', '--api-endpoint URL', 'Travis API server to talk to')
      on('--pro', "short-cut for --api-endpoint '#{Travis::Client::PRO_URI}'") { |c| c.api_endpoint = Travis::Client::PRO_URI }
      on('--org', "short-cut for --api-endpoint '#{Travis::Client::ORG_URI}'") { |c| c.api_endpoint = Travis::Client::ORG_URI }
      on('-t', '--token [ACCESS_TOKEN]', 'access token to use')

      def setup
        options = {}
        options[:access_token] = token        if token
        options[:url]          = api_endpoint if api_endpoint
        self.client            = Travis::Client.new(options)
      end

      def authenticate
      end
    end
  end
end
