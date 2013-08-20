require 'travis/cli'

module Travis
  module CLI
    class Restart < RepoCommand
      description "restarts a build or job"

      def run(number = last_build.number)
        authenticate
        entity = job(number) || build(number)
        error "could not find job or build #{repository.slug}##{number}" unless entity
        entity.restart

        say "restarted", "#{entity.class.one} ##{entity.number} has been %s"
      end
    end
  end
end
