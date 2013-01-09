require 'travis/cli'

module Travis
  module CLI
    class Help < Command
      def run(command = nil)
        if command
          puts CLI.command(command).new.help
        else
          puts "Usage: #$0 COMMAND ...", "", "Available commands:", ""
          CLI.commands.each { |c| puts "\t#{c.command_name}" }
          puts "", "run `#$0 help COMMAND` for more infos"
        end
      end
    end
  end
end
