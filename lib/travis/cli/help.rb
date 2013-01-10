require 'travis/cli'

module Travis
  module CLI
    class Help < Command
      def run(command = nil)
        if command
          say CLI.command(command).new.help
        else
          say "Usage: #$0 COMMAND ...\n\nAvailable commands:\n\n"
          CLI.commands.each { |c| say "\t#{c.command_name}" }
          say "\nrun `#$0 help COMMAND` for more infos"
        end
      end
    end
  end
end
