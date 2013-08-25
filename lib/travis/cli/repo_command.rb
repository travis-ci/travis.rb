require 'travis/cli'
require 'yaml'

module Travis
  module CLI
    class RepoCommand < ApiCommand
      GIT_REGEX = %r{^(?:https://|git://|git@)github\.com[:/](.*/.+?)(\.git)?$}
      on('-r', '--repo SLUG', 'repository to use (will try to detect from current git clone)') { |c, slug| c.slug = slug }

      attr_accessor :slug
      abstract

      def setup
        error "Can't figure out GitHub repo name. Ensure you're in the repo directory, or specify the repo name via the -r option (e.g. travis <command> -r <repo-name>)" unless self.slug ||= find_slug
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
          git_head   = `git name-rev --name-only HEAD 2>#{IO::NULL}`.chomp
          git_remote = `git config --get branch.#{git_head}.remote 2>#{IO::NULL}`.chomp
          git_remote = 'origin' if git_remote.empty?
          git_info   = `git config --get remote.#{git_remote}.url 2>#{IO::NULL}`.chomp
          $1 if git_info =~ GIT_REGEX
        end

        def repo_config
          config['repos'] ||= {}
          config['repos'][slug] ||= {}
        end

        def detect_api_endpoint
          if explicit_api_endpoint?
            repo_config['endpoint'] = api_endpoint
          elsif ENV['TRAVIS_ENDPOINT']
            ENV['TRAVIS_ENDPOINT']
          else
            repo_config['endpoint'] ||= begin
              GH.head("/repos/#{slug}")
              Travis::Client::ORG_URI
            rescue GH::Error
              Travis::Client::PRO_URI
            end
          end
        end

        def travis_config
          @travis_config ||= begin
            payload = YAML.load_file(travis_yaml)
            payload.respond_to?(:to_hash) ? payload.to_hash : {}
          end
        end

        def travis_yaml(dir = Dir.pwd)
          path = File.expand_path('.travis.yml', dir)
          if File.exist? path
            path
          else
            parent = File.expand_path('..', dir)
            error "no .travis.yml found" if parent == dir
            travis_yaml(parent)
          end
        end

        def save_travis_config(file = travis_yaml)
          yaml = travis_config.to_yaml
          yaml.gsub! /^(\s+)('on'|true):/, "\\1on:"
          yaml.gsub! /\A---\s*\n/, ''
          File.write(file, yaml)
        end
    end
  end
end
