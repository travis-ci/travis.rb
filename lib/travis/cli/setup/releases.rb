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
            if config['api_key'].nil?
              raise Travis::Client::GitHubLoginFailed, 'all GitHub tokens given were invalid'
            end

            config['file'] = ask("File to Upload: ").to_s
          end
        end

        def github
          @github ||= begin
            load_gh
            Tools::Github.new(session.config['github']) do |g|
              g.drop_token    = false
              g.github_token  = github_token
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
