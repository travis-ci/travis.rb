require 'travis/cli/setup'
require 'travis/tools/github'

module Travis
  module CLI
    class Setup
      class Releases < Service
        description "Upload Assets to GitHub Releases"

        def run
          deploy 'releases' do |config|
            github.with_token { |t| config['api_key'] = t }
            config['file'] = ask("File to Upload: ").to_s
          end
        end

        def github
          @github ||= begin
            load_gh
            Tools::Github.new(session.config['github']) do |g|
              g.drop_token    = false
              g.ask_login     = proc { ask("Username: ") }
              g.ask_password  = proc { |user| ask("Password for #{user}: ") { |q| q.echo = "*" } }
              g.ask_otp       = proc { |user| ask("Two-factor authentication code for #{user}: ") }
              g.debug         = proc { |log| debug(log) }
              g.after_tokens  = proc { g.explode = true and error("no suitable github token found") }
              g.scopes        = org? ? ['public_repo'] : ['repo']
              g.note          = "automatic releases for #{repository.slug}"
            end
          end
        end
      end
    end
  end
end