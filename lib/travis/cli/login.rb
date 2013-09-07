require 'travis/cli'
require 'travis/tools/token_finder'
require 'json'

module Travis
  module CLI
    class Login < ApiCommand
      description "authenticates against the API and stores the token"
      on '--github-token TOKEN', 'identify by GitHub token'
      on '--auto', 'try to figure out who you are automatically (might send another apps token to Travis, token will not be stored)'

      skip :authenticate
      attr_accessor :github_login, :github_password, :github_token, :github_otp, :callback

      def run
        self.github_token ||= Travis::Tools::TokenFinder.find(:explode => explode?, :github => github_endpoint.host) if auto?
        generate_github_token unless github_token
        endpoint_config['access_token'] = github_auth(github_token)
        success("Successfully logged in!")
      ensure
        callback.call if callback
      end

      private

        def generate_github_token
          load_gh
          ask_info

          options = { :username => github_login, :password => github_password }
          options[:headers] = { "X-GitHub-OTP" => github_otp } if github_otp
          gh = GH.with(options)

          reply = gh.post('/authorizations', :scopes => github_scopes, :note => "temporary token to identify on #{api_endpoint}")

          self.github_token = reply['token']
          self.callback     = proc { gh.delete reply['_links']['self']['href'] }
        rescue GH::Error => error
          if error.info[:response_status] == 401
            ask_2fa
            generate_github_token
          else
            raise error if explode?
            error(JSON.parse(error.info[:response_body])["message"])
          end
        end

        def github_scopes
          ['user:email', org? ? 'public_repo' : 'repo']
        end

        def ask_info
          return if !github_login.nil?
          say "We need your #{color("GitHub login", :important)} to identify you."
          say "This information will #{color("not be sent to Travis CI", :important)}, only to #{color(github_endpoint.host, :info)}."
          say "The password will not be displayed."
          empty_line
          say "Try running with #{color("--github-token", :info)} or #{color("--auto", :info)} if you don't want to enter your password anyways."
          empty_line
          self.github_login    = ask("Username: ")
          self.github_password = ask("Password: ") { |q| q.echo = "*" }
          empty_line
        end

        def ask_2fa
          self.github_otp = ask "Two-factor authentication code: "
          empty_line
        end
    end
  end
end
