require 'travis/cli'

module Travis
  module CLI
    class Overview < RepoCommand
      description "shows overview"
      subcommands :branches, :duration, :history, :eventType, :streak

      def setup
        super
        authenticate
        error "not allowed to access overview for #{color(repository.slug, :bold)}" unless repository.admin?
      end


      def branches
        result = session.get_raw("v3/repo/#{repository.id}/overview/branches")
        info "Passing builds in last 30 days"
        info "No data" unless !result['branches'].empty?
        result['branches'].each_pair do | key, value |
          say "#{key}: #{100*value.to_i}%"
        end
      end

      def duration
        result = session.get_raw("v3/repo/#{repository.id}/overview/build_duration")
        info "Duration of last 20 builds"
        info "No data" unless !result['build_duration'].empty?
        result['build_duration'].each do | build |
          say "Build #{build['number']} #{build['state']} in #{build['duration']} seconds"
        end
      end

      def history
        result = session.get_raw("v3/repo/#{repository.id}/overview/build_history")
        info "Build statuses in last 10 days"
        info "No data" unless !result['recent_build_history'].empty?
        result['recent_build_history'].each_pair do | key, value |
          say "#{key}:"
          value.each_pair do | key2, value2 |
            say "   #{key2}: #{value2}"
          end
        end
      end

      def eventType
        result = session.get_raw("v3/repo/#{repository.id}/overview/event_type")
        info "Statuses by event type"
        info "No data" unless !result['event_type'].empty?
        result['event_type'].each_pair do | key, value |
          say "#{key}:"
          value.each_pair do | key2, value2 |
            say "   #{key2}: #{value2}"
          end
        end
      end

      def streak
        result = session.get_raw("v3/repo/#{repository.id}/overview/streak")
        info "Your streak is #{result['streak']['days']} days and #{result['streak']['builds']} builds."
      end

    end
  end
end
