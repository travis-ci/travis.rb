require 'travis/client'
require 'travis/tools/github'
require 'yaml'

module Travis
  module Client
    class AutoLogin
      NoTokenError = Class.new(RuntimeError)
      attr_reader :session

      def initialize(session, options = {})
        @session     = session.session
        config_path  = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', Dir.home) }
        @config_file = options.fetch(:config_file) { File.expand_path('config.yml', config_path) }
        @auto_token  = options.fetch(:auto_token) { true }
        @raise       = options.fetch(:raise) { true }
      end

      def authenticate
        return if session.access_token = cli_token
        github.with_token { |t| session.github_auth(t) }
      end

      def github
        @github         ||= Tools::Github.new(session.config['github']) do |g|
          g.explode       = true
          g.auto_token    = @auto_token
          g.after_tokens  = proc { raise NoTokenError, "no suitable github token found" } if @raise
        end
      end

      def cli_token
        result   = cli_config
        result &&= result['endpoints']
        result &&= result[session.uri]
        result &&  result['access_token']
      end

      def cli_config
        @cli_config ||= YAML.load_file(@config_file) if File.exist? @config_file
      end
    end
  end
end
