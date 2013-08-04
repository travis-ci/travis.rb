require 'travis/cli'

module Travis
  module CLI
    class Monitor < ApiCommand
      on('-m', '--my-repos', 'Only monitor my own repositories')
      on('-r', '--repo SLUG', 'monitor given repository (can be used more than once)') do |c, slug|
        c.repos << slug
      end

      attr_reader :repos

      def initialize(*)
        @repos = []
        super
      end

      def setup
        super
        repos.map! { |r| repo(r) }
        repos.concat(user.repositories) if my_repos?
      end

      def description
        case repos.size
        when 0 then session.config['host']
        when 1 then repos.first.slug
        else "#{repos.size} repositories"
        end
      end

      def run
        listen(*repos) do |listener|
          listener.on_connect { say description, 'Monitoring %s:' }
          listener.on 'build:started', 'job:started', 'build:finished', 'job:finished' do |event|
            entity = event.job          || event.build
            time   = entity.finished_at || entity.started_at
            say [
              color(formatter.time(time), entity.color),
              color(entity.inspect_info, [entity.color, :bold]),
              color(entity.state, entity.color)
            ].join(" ")
          end
        end
      end
    end
  end
end
