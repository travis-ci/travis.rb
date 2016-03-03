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
          result['crons'].each do |cron|
            say "Cron #{cron.id} builds #{cron.interval} on #{cron.branch_name}."
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
