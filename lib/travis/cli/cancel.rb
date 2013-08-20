require 'travis/cli'

module Travis
  module CLI
    class Cancel < RepoCommand
      description "cancels a job or build"

      def run(number = last_build.number)
        authenticate
        entity = job(number) || build(number)
        error "could not find job or build #{repository.slug}##{number}" unless entity
        entity.cancel

        say "canceled", "#{entity.class.one} ##{entity.number} has been %s"
      end
    end
  end
end
