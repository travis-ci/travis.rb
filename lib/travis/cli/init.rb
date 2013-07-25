require 'travis/cli'

module Travis
  module CLI
    class Init < RepoCommand
      on('-f', '--force', 'override .travis.yml if it already exists')
      attr_writer :travis_config

      def run(language = nil)
        error ".travis.yml already exists, use --force to override" if File.exist?('.travis.yml') and not force?
        language ||= ask('Main programming language used: ') { |q| q.default = detect_language }
        self.travis_config = template(language)
        save_travis_config('.travis.yml')
        say(".travis.yml file created!")
      end

      private

        def template(language)
          file = File.expand_path("../init/#{language}.yml", __FILE__)
          error "unknown language #{language}" unless File.exist? file
          YAML.load_file(file)
        end

        def detect_language
          'ruby'
        end
    end
  end
end