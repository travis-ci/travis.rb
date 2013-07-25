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

      private

        def travis_yaml_exists_and_overwrite(dir = Dir.pwd)
          path = File.expand_path('.travis.yml', dir)
          if File.exist? path
            if agree(".travis.yml already exists, do you want to overwrite?")
              File.delete(path)
              say "File overwritten!"
            else
              error "You chose not to overwrite, task cancelled."
            end
          end
        end

        def travis_config_template(language)
          payload = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), "init/#{language}.yml"))
        end
    end
  end
end