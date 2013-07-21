require 'travis/cli'

module Travis
  module CLI
    class Whatsup < ApiCommand
      on('-m', '--my-repos')

      def run
        recent.each do |repo|
          say [
            color(repo.slug, [:bold, repo.color]),
            color("#{repo.last_build.state}: ##{repo.last_build.number}", repo.color)
          ].join(" ")
        end
      end

      private

        def recent
          return repos unless my_repos
          repos(:member => user.login)
        end
    end
  end
end
