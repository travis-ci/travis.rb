require 'travis/cli'

module Travis
  module CLI
    class Init < Command
      def run
        check_already_exists
        create_travis_file
      end

      private

      def check_already_exists
        if File.exist?('.travis.yml')
          answer = ask(".travis.yml already exists, do you want to overwrite?")
          if answer =~ (/(true|t|yes|y|1)$/i)
            File.delete('.travis.yml')
            say "File overwritten!"
          else
            error "You chose not to overwrite, task cancelled."
          end
        end
      end

      def create_travis_file
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

    end
  end
end