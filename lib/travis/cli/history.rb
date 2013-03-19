require 'travis/cli'

module Travis
  module CLI
    class History < RepoCommand
      on('-a', '--after BUILD', 'Only show history after a given build number')
      on('-p', '--pull-request NUMBER', 'Only show history for the given Pull Request')
      on('-b', '--branch BRANCH', 'Only show history for the given branch')
      on('-l', '--limit LIMIT', 'Maximum number of history items')
      on('--[no-]all', 'Display all history items')

      def run
        countdown = Integer(limit || 10) unless all?
        params    = { :after_number => after } if after
        repository.each_build(params) do |build|
          next unless display? build
          display(build)

          if countdown
            countdown -= 1
            break if countdown < 1
          end
        end
      end

      private

        def display?(build)
          return build.pr_number   == pull_request if pull_request
          return build.branch_info == branch       if branch
          true
        end

        def display(build)
          say [
            color("##{build.number} #{build.state}:".ljust(16), [build.color, :bold]),
            color("#{build.branch_info} ", :info),
            build.commit.subject
          ].join
        end
    end
  end
end
