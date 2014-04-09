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
      on('-p', '--auto-password',      'try to load password from OSX keychain (will not be stored)')
      on('-a', '--auto',               'shorthand for --auto-token --auto-password') { |c| c.auto_token = c.auto_password = true }
      on('-u', '--user LOGIN',         'user to log in as') { |c,n| c.user_login = n }
      on('-M', '--no-manual',          'do not use interactive login')
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
          success("Successfully logged in as #{user.login}!")
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
            g.manual_login  = no_manual.nil?
            g.explode       = explode?
            g.github_token  = github_token
            g.auto_token    = auto_token
            g.auto_password = auto_password
            g.github_login  = user_login
            g.check_token   = !skip_token_check?
            g.drop_token    = true
            g.ask_login     = proc { ask("Username: ") }
            g.ask_password  = proc { |user| ask("Password for #{user}: ") { |q| q.echo = "*" } }
            g.ask_otp       = proc { |user| ask("Two-factor authentication code for #{user}: ") }
            g.login_header  = proc { login_header }
            g.debug         = proc { |log| debug(log) }
            g.after_tokens  = proc { g.explode = true and error("no suitable github token found") }
          end
        end
      end

      def login_header
        say "We need your #{color("GitHub login", :important)} to identify you."
        say "This information will #{color("not be sent to Travis CI", :important)}, only to #{color(github_endpoint.host, :info)}."
        say "The password will not be displayed."
        empty_line
        say "Try running with #{color("--github-token", :info)} or #{color("--auto", :info)} if you don't want to enter your password anyways."
        empty_line
      end
    end
  end
end
