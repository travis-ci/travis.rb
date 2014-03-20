require 'travis/cli'

module Travis
  module CLI
    class Help < Command
      description "helps you out when in dire need of information"

      def run(command = nil)
        if command
          say CLI.command(command).new.help
        else
          say "Usage: travis COMMAND ...\n\nAvailable commands:\n\n"
          
          commands.each do |group, commands|
            say "  #{group}"
            commands.each do |c|
              say "\t#{color(c.command_name, :command).ljust(20)} #{color(c.description, :info)}"
            end
            say "\n"
          end
          
          say "\nrun `#$0 help COMMAND` for more infos"
        end
      end

      def commands
        command_hash = {
          'General Commands'    => [],
          'API Commands'        => [],
          'Repository Commands' => []
        }
        
        CLI.commands.each do |cmd|
          if cmd.superclass.equal? Travis::CLI::ApiCommand
            command_hash['API Commands'].push cmd
          elsif cmd.superclass.equal? Travis::CLI::RepoCommand
            command_hash['Repository Commands'].push cmd
          else
            command_hash['General Commands'].push cmd
          end
        end
        
        # sort values for each key
        command_hash.each { |key, commands| commands.sort_by &:command_name }
      end
    end
  end
end
