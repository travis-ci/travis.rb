require 'travis/cli'

module Travis
  module CLI
    class Branches < RepoCommand
      description "displays the most recent build for each branch"

      def run
        repository.last_on_branch.each do |build|
          say [
            color("#{build.branch_info}:".ljust(longest + 2), [:info, :bold]),
            color("##{build.number.to_s.ljust(4)} #{build.state}".ljust(16), build.color),
            build.commit.subject
          ].join(" ").strip + "\n"
        end
      end

      private

        def longest
          repository.branches.keys.map { |b| b.size }.max
        end
    end
  end
end
