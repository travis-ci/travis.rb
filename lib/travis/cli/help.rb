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
          commands.each { |c| say "\t#{color(c.command_name, :command).ljust(22)} #{color(c.description, :info)}" }
          say "\nrun `#$0 help COMMAND` for more infos"
        end
      end

      def commands
        CLI.commands.sort_by { |c| c.command_name }
      end
    end
  end
end
