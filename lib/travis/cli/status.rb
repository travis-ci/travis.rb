require 'travis/cli'

module Travis
  module CLI
    class Status < RepoCommand
      description "checks status of the latest build"

      on '-b', '--branch BRANCH',     'only check status for the given branch'
      on '-x', '--[no-]exit-code',    'sets the exit code to 1 if the build failed'
      on '-q', '--[no-]quiet',        'does not print anything'
      on '-p', '--[no-]fail-pending', 'sets the status code to 1 if the build is pending'

      def run
        say color(last_build.state, last_build.color), "build ##{last_build.number} %s" unless quiet?
        exit 1 if exit_code?    and last_build.unsuccessful?
        exit 1 if fail_pending? and last_build.pending?
      end

      private

        def last_build
          return super unless branch?
          repository.last_on_branch(branch)
        end
    end
  end
end
