require 'travis/cli'

module Travis
  module CLI
    class Overview < RepoCommand
      description "shows statistics"
      subcommands :branches, :duration, :history, :eventType, :streak

      def setup
        super
        authenticate
      end


      def branches
        result = session.get_raw("v3/repo/#{repository.id}/overview/branches")
        say color("passing builds in last 30 days", :info)
        info "no data" if result['branches'].empty?
        result['branches'].each_pair do | key, value |
          say "#{key}: #{(100*value).round}%"
        end
      end

      def duration
        result = session.get_raw("v3/repo/#{repository.id}/overview/build_duration")
        say color("duration of last 20 builds", :info)
        info "no data" if result['build_duration'].empty?
        result['build_duration'].each do | build |
          say "build #{build['number']} #{build['state']} in #{build['duration']} seconds"
        end
      end

      def history
        result = session.get_raw("v3/repo/#{repository.id}/overview/build_history")
        say color("build statuses in last 10 days", :info)
        info "no data" if result['recent_build_history'].empty?
        result['recent_build_history'].each_pair do | key, value |
          say "#{key}:"
          value.each_pair do | key2, value2 |
            say "   #{key2}: #{value2}"
          end
        end
      end

      def eventType
        result = session.get_raw("v3/repo/#{repository.id}/overview/event_type")
        say color("statuses by event type", :info)
        info "no data" if result['event_type'].empty?
        result['event_type'].each_pair do | key, value |
          say "#{key}:"
          value.each_pair do | key2, value2 |
            say "   #{key2}: #{value2}"
          end
        end
      end

      def streak
        result = session.get_raw("v3/repo/#{repository.id}/overview/streak")
        say "Your streak is #{result['streak']['days']} days and #{result['streak']['builds']} builds."
      end

    end
  end
end
