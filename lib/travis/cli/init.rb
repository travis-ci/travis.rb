require 'travis/cli'

module Travis
  module CLI
    class Init < RepoCommand
      def run(language = nil)
        error "no language given." if language.nil?
        error "unknown language #{language}" unless respond_to? "create_travis_file_for_#{language}"
        travis_yaml_exists_and_overwrite
        public_send "create_travis_file_for_#{language}"
      end

      def create_travis_file_for_ruby
        content = <<-EOF
        language: ruby
        rvm:
        - 1.9.2
        - 1.9.3
        - 2.0.0
        EOF
        File.open(".travis.yml", 'w') do |f|
          f.puts content
        end
        say ".travis.yml file created!"
      end

      # private

      # def check_already_exists
      #   if File.exist?('.travis.yml')
      #     if agree(".travis.yml already exists, do you want to overwrite?")
      #       File.delete('.travis.yml')
      #       say "File overwritten!"
      #     else
      #       error "You chose not to overwrite, task cancelled."
      #     end
      #   end
      # end

    end
  end
end