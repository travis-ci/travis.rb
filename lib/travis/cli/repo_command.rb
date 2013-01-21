require 'travis/cli'

module Travis
  module CLI
    class RepoCommand < ApiCommand
      GIT_REGEX = %r{Fetch URL: (?:https://|git://|git@)github\.com[:/](.*/.+?)(\.git)?$}
      on('-r', '--repo SLUG') { |c, slug| c.slug = slug }

      attr_accessor :slug
      abstract

      def setup
        error "Can't figure out GitHub repo name. Are you in the right directory?" unless self.slug ||= find_slug
        self.api_endpoint = detect_api_endpoint
        super
        repository.load # makes sure we actually have access to the repo
      end

      def repository
        repo(slug)
      rescue Travis::Client::NotFound
        error "repository not known to #{api_endpoint}: #{color(slug, :important)}"
      end

      private

        def build(number_or_id)
          return super if number_or_id.is_a? Integer
          repository.build(number_or_id)
        end

        def job(number_or_id)
          return super if number_or_id.is_a? Integer
          repository.job(number_or_id)
        end

        def last_build
          repository.last_build or error("no build yet for #{slug}")
        end

        def detected_endpoint?
          !explicit_api_endpoint?
        end

        def find_slug
          git_info = `git remote show origin 2>&1`
          $1 if git_info =~ GIT_REGEX
        end

        def repo_config
          config['repos'] ||= {}
          config['repos'][slug] ||= {}
        end

        def detect_api_endpoint
          if explicit_api_endpoint?
            repo_config['endpoint'] = api_endpoint
          else
            repo_config['endpoint'] ||= begin
              GH.head("/repos/#{slug}")
              Travis::Client::ORG_URI
            rescue GH::Error
              Travis::Client::PRO_URI
            end
          end
        end
    end
  end
end
