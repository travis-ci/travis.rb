require 'travis/cli'

module Travis
  module CLI
    class History < RepoCommand
      description "displays a project's build history"

      on('-a', '--after BUILD', 'Only show history after a given build number')
      on('-p', '--pull-request NUMBER', 'Only show history for the given Pull Request')
      on('-b', '--branch BRANCH', 'Only show history for the given branch')
      on('-l', '--limit LIMIT', 'Maximum number of history items')
      on('-d', '--date', 'Include date in output')
      on('-t', '--duration', 'Include build time in secs in output')
      on('-c', '--committer', 'Include committer in output')
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
          return build.pr_number   == pull_request.to_i if pull_request
          return build.branch_info == branch            if branch
          true
        end

        def display(build)
          say [
            date? && color(formatter.time(build.finished_at || build.started_at), build.color),
            color("##{build.number} #{build.state}:".ljust(16), [build.color, :bold]),
            duration? && color(build.duration.to_s.ljust(6), :info),
            color("#{build.branch_info}", :info),
            committer? && build.commit.author_name.ljust(25),
            build.commit.subject
          ].compact.join(" ").strip + "\n"
        end
    end
  end
end
