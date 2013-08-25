require 'travis/cli'
require 'travis/tools/token_finder'
require 'json'

module Travis
  module CLI
    class Login < ApiCommand
      description "authenticates against the API and stores the token"

      skip :authenticate
      attr_accessor :github_login, :github_password, :github_token, :callback

      on('--github-token TOKEN', 'identify by GitHub token')

      on('--auto', 'try to figure out who you are automatically (might send another apps token to Travis, token will not be stored)') do |c|
        c.github_token ||= Travis::Tools::TokenFinder.find(:explode => c.explode?)
      end

      def run
        generate_github_token unless github_token
        endpoint_config['access_token'] = github_auth(github_token)
        success("Successfully logged in!")
      ensure
        callback.call if callback
      end

      private

        def generate_github_token
          ask_info
          load_gh

          gh    = GH.with(:username => github_login, :password => github_password)
          reply = gh.post('/authorizations', :scopes => github_scopes, :note => "temporary token to identify on #{api_endpoint}")

          self.github_token = reply['token']
          self.callback     = proc { gh.delete reply['_links']['self']['href'] }
        rescue GH::Error => e
          raise e if explode?
          error JSON.parse(e.info[:response_body])["message"]
        end

        def github_scopes
          ['user:email', org? ? 'public_repo' : 'repo']
        end

        def ask_info
          say "We need your #{color("GitHub login", :important)} to identify you."
          say "This information will #{color("not be sent to Travis CI", :important)}, only to GitHub."
          say "The password will not be displayed."
          empty_line
          say "Try running with #{color("--github-token", :info)} or #{color("--auto", :info)} if you don't want to enter your password anyways."
          empty_line
          self.github_login    = ask("Username: ")
          self.github_password = ask("Password: ") { |q| q.echo = "*" }
          empty_line
        end
    end
  end
end
