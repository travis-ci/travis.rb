require 'travis/cli'

module Travis
  module CLI
    class Help < Command
      description "helps you out when in dire need of information"

      CommandGroup = Struct.new(:cmds, :header)

      def run(command = nil)
        if command
          say CLI.command(command).new.help
        else
          api_cmds   = CommandGroup.new(api_commands,   'API commands')
          repo_cmds  = CommandGroup.new(repo_commands,  'Repo commands')
          other_cmds = CommandGroup.new(other_commands, 'non-API commands')

          say "Usage: travis COMMAND ...\n\nAvailable commands:\n\n"
          [other_cmds, api_cmds, repo_cmds].each do |cmd_grp|
            say "    #{cmd_grp.header}"
            cmd_grp.cmds.each do |cmd|
              say "        #{color(cmd.command_name, :command).ljust(22)} #{color(cmd.description, :info)}"
            end
          end
          say "\nrun `#$0 help COMMAND` for more info"
        end
      end

      def cmd_group_header(title)
        say "    #{color(title, :green)}"
      end

      def api_commands
        CLI.commands.select do |cmd|
          cmd.ancestors.include?(CLI::ApiCommand) &&
          !cmd.ancestors.include?(CLI::RepoCommand)
        end.sort_by {|c| c.command_name}
      end

      def repo_commands
        CLI.commands.select do |cmd|
          cmd.ancestors.include? CLI::RepoCommand
        end.sort_by {|c| c.command_name}
      end

      def other_commands
        CLI.commands.select do |cmd|
          !cmd.ancestors.include? CLI::ApiCommand
        end.sort_by {|c| c.command_name}
      end
    end
  end
end
