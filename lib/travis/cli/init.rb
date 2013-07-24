require 'travis/cli'

module Travis
  module CLI
    class Init < RepoCommand

      LANGUAGES = ['ruby']

      def run(language = nil)
        error "no language given." if language.nil?
        error "unknown language #{language}" unless LANGUAGES.include?(language)
        travis_yaml_exists_and_overwrite
        create_travis_file(language)
      end

      def create_travis_file(language)
        content = travis_config_template(language)
        File.open(".travis.yml", 'w') do |f|
          f.puts content
        end
        say ".travis.yml file created!"
      end

    end
  end
end