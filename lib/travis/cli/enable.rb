require 'travis/cli'

module Travis
  module CLI
    class Enable < RepoCommand
      description "enables a project"
      on('-s', '--skip-sync', "don't trigger a sync if the repo is unknown")

      def run
        authenticate
        error "not allowed to update service hook for #{color(repository.slug, :bold)}" unless repository.admin?
        repository.enable
        say "enabled", color("#{slug}: %s :)", :success)
      end

      private

        def repository
          repo(slug)
        rescue Travis::Client::NotFound
          unless skip_sync?
            say "repository not known to Travis CI (or no access?)"
            say "triggering sync: "
            sync
            say " done"
          end
          super
        end
    end
  end
end
