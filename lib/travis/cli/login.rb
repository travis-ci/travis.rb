require 'travis/cli'
require 'travis/tools/github'
require 'json'

module Travis
  module CLI
    class Login < ApiCommand
      skip :authenticate

      description "authenticates against the API and stores the token"
      on('-g', '--github-token TOKEN', 'identify by GitHub token')
      on('-T', '--auto-token',         'try to figure out who you are automatically (might send another apps token to Travis, token will not be stored)')
      on('--list-github-token',        'instead of actually logging in, list found GitHub tokens')
      on('--skip-token-check',         'don\'t verify the token with github')

      attr_accessor :user_login

      def list_token
        github.after_tokens = proc { }
        github.each_token do |token|
          say token
        end
      end

      def login
        session.access_token = nil
        github.with_token do |token|
          endpoint_config['access_token'] = github_auth(token)
          error("user mismatch: logged in as %p instead of %p" % [user.login, user_login]) if user_login and user.login != user_login
          unless user.correct_scopes?
            error(
              "#{user.login} has not granted Travis CI the required permissions. " \
              "Please try re-syncing your user data at https://#{session.config['host']}/account/preferences " \
              "and try logging in via #{session.config['host']}"
            )
          end
          success("Successfully logged in as #{user.login}!")
        end

        unless session.access_token
          raise Travis::Client::GitHubLoginFailed, "all GitHub tokens given were invalid"
        end
      end

      def run
        list_github_token ? list_token : login
      end

      def github
        @github ||= begin
          load_gh
          Tools::Github.new(session.config['github']) do |g|
            g.note          = "temporary token to identify with the travis command line client against #{api_endpoint}"
            g.explode       = explode?
            g.github_token  = github_token
            g.auto_token    = auto_token
            g.check_token   = !skip_token_check?
            g.drop_token    = !list_github_token
            g.login_header  = proc { login_header }
            g.debug         = proc { |log| debug(log) }
            g.after_tokens  = proc { g.explode = true and error("no suitable github token found") }
          end
        end
      end

      def login_header
        say "GitHub deprecated its Authorizations API exchanging a password for a token."
        say "Please visit https://github.blog/2020-07-30-token-authentication-requirements-for-api-and-git-operations for more information."
        say "Try running with #{color("--github-token", :info)} or #{color("--auto-token", :info)} ."
      end
    end
  end
end
