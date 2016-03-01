require 'travis/cli'

module Travis
  module CLI
    class Crons < ApiCommand
      description "lists crons for all repos"
      on('-m', '--my-repos', 'Only display my own repositories')

      def run
        say "nothing to show" if recent.empty?
        recent.each do |repo|
          result = session.get("v3/repo/#{repo.id}/crons")
          say color(repo.slug, [:bold, repo.color])
          result['crons'].each do | cron |
            say 'ID: ' + cron.id.to_s
            say 'Branch: ' + cron.branch_name
            say 'Interval: ' + cron.interval
            say 'Disable by build: ' + cron.disable_by_build.to_s
            say 'Next Enqueuing: ' + cron.next_enqueuing
            say "\n"
          end
        end
      end

      private

        def recent
          @recent ||= begin
            recent = my_repos ? repos : repos(:member => user.login)
            recent.select { |repo| repo.last_build }
          end
        end
    end
  end
end
