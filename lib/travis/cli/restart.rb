require 'travis/cli'

module Travis
  module CLI
    class Restart < RepoCommand
      def run(number = last_build.number)
        authenticate
        entity = job(number) || build(number)
        entity.restart

        say "restarted", "#{entity.class.one} ##{entity.number} has been %s"
      end
    end
  end
end
