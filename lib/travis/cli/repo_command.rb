require 'travis/cli'
require 'yaml'

module Travis
  module CLI
    class RepoCommand < ApiCommand
      GIT_REGEX = %r{/?(.*/.+?)(\.git)?$}
      TRAVIS    = %r{^https://(staging-)?api\.travis-ci\.(org|com)}
      on('-r', '--repo SLUG', 'repository to use (will try to detect from current git clone)') { |c, slug| c.slug = slug }
      on('-R', '--store-repo SLUG', 'like --repo, but remembers value for current directory') do |c, slug|
        c.slug = slug
        c.send(:store_slug, slug)
      end

      attr_accessor :slug
      abstract

      def setup
        setup_enterprise
        error "Can't figure out GitHub repo name. Ensure you're in the repo directory, or specify the repo name via the -r option (e.g. travis <command> -r <owner>/<repo>)" unless self.slug ||= find_slug
        error "GitHub repo name is invalid, it should be of the form 'owner/repo'" unless self.slug.include?("/")
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

        def branch(name)
          repository.branch(name)
        end

        def last_build
          repository.last_build or error("no build yet for #{slug}")
        end

        def detected_endpoint?
          !explicit_api_endpoint?
        end

        def find_slug
          load_slug || begin
            slug = detect_slug
            interactive? ? store_slug(slug) : slug if slug
          end
        end

        def detect_slug
          git_head    = `git name-rev --name-only HEAD 2>#{IO::NULL}`.chomp
          git_remote  = `git config --get branch.#{git_head}.remote 2>#{IO::NULL}`.chomp
          git_remote  = 'origin' if git_remote.empty?
          git_info    = `git ls-remote --get-url #{git_remote} 2>#{IO::NULL}`.chomp

          if parse_remote(git_info) =~ GIT_REGEX
            detected_slug = $1
            if interactive?
              if agree("Detected repository as #{color(detected_slug, :info)}, is this correct? ") { |q| q.default = 'yes' }
                detected_slug
              else
                ask("Repository slug (owner/name): ") { |q| q.default = detected_slug }
              end
            else
              info "detected repository as #{color(detected_slug, :bold)}"
              detected_slug
            end
          end
        end

        def parse_remote(url)
          if url =~ /^git@[^:]+:/
            path = url.split(':').last
            path = "/#{path}" unless path.start_with?('/')
            path
          else
            URI.parse(url).path
          end
        end

        def load_slug
          stored = `git config --get travis.slug`.chomp
          stored unless stored.empty?
        end

        def store_slug(value)
          `git config travis.slug #{value}` if value
          value
        end

        def repo_config
          config['repos'] ||= {}
          config['repos'][slug] ||= {}
        end

        def detect_api_endpoint
          if explicit_api_endpoint? or enterprise?
            repo_config['endpoint'] = api_endpoint
          elsif ENV['TRAVIS_ENDPOINT']
            ENV['TRAVIS_ENDPOINT']
          elsif config['default_endpoint'] and config['default_endpoint'] !~ TRAVIS
            repo_config['endpoint'] ||= config['default_endpoint']
          else
            repo_config['endpoint'] ||= begin
              load_gh
              GH.head("/repos/#{slug}")
              Travis::Client::ORG_URI
            rescue GH::Error
              Travis::Client::COM_URI
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

        def confirm_and_save_travis_config(confirm = true, file = travis_yaml)
          if confirm
            ans = ask [
              nil,
              color("Overwrite the config file #{travis_yaml} with the content below?", [:info, :yellow]),
              color("This reformats the existing file.", [:info, :red]),
              travis_config.to_yaml,
              color("(y/N)", [:info, :yellow])
            ].join("\n\n")
            confirm = ans =~ /^y/i
          end

          save_travis_config if confirm
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
