require 'travis/cli'

module Travis
  module CLI
    class Whatsup < ApiCommand
      description "lists most recent builds"
      on('-m', '--my-repos', 'Only display my own repositories')

      def run
        say "nothing to show" if recent.empty?

        recent.each do |repo|
          say [
            color(repo.slug, [:bold, repo.color]),
            color("#{repo.last_build.state}: ##{repo.last_build.number}", repo.color)
          ].join(" ")
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
