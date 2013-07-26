require 'travis/cli'

module Travis
  module CLI
    class Init < Enable
      on('-f', '--force', 'override .travis.yml if it already exists')
      on('-k', '--skip-enable', 'do not enable project, only add .travis.yml')
      attr_writer :travis_config

      def run(language = nil, file = '.travis.yml')
        error ".travis.yml already exists, use --force to override" if File.exist?(file) and not force?
        language ||= ask('Main programming language used: ') { |q| q.default = detect_language }
        self.travis_config = template(language)
        save_travis_config(file)
        say("#{file} file created!")
        super() unless skip_enable?
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