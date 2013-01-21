require 'travis/cli'

module Travis
  module CLI
    class Whatsup < ApiCommand
      def run
        repos.each do |repo|
          say [
            color(repo.slug, [:bold, repo.color]),
            color("#{repo.last_build.state}: ##{repo.last_build.number}", repo.color)
          ].join(" ")
        end
      end
    end
  end
end
