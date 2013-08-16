require 'travis/cli'

module Travis
  module CLI
    class Cancel < RepoCommand
      def run(number = last_build.number)
        authenticate
        entity = job(number) || build(number)
        entity.cancel

        say "canceled", "#{entity.class.one} ##{entity.number} has been %s"
      end
    end
  end
end
