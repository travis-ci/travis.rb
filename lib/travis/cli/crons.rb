require 'travis/cli'

module Travis
  module CLI
    class Crons < ApiCommand
      description "lists all cron jobs of all repositories"
      on('-m', '--my-repos', 'Only display my own repositories')

      def run
        say "nothing to show" if recent.empty?
        recent.each do |repo|
          result = session.get("v3/repo/#{repo.id}/crons")
          say color(repo.slug, [:bold, repo.color])
          result['crons'].each do |cron|
            say "Cron " +
              color("#{cron.id}", :bold) +
              " builds " +
              color("#{cron.interval}", :bold) +
              " on " +
              color("#{cron.branch_name}", :bold) +
              "."
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
