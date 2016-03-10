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
	if result['recent_build_history'].empty?
		info "no data"
		return
	end 
	string = ""
	max = 1
	maxStatuses = 1	
	result['recent_build_history'].each_pair do | key, value |
		builds = 0
		value.each_value do |v|
			builds= builds+v
		end
		maxStatuses = value.size if value.size > maxStatuses
		max = builds if builds > max
	end
        (0..9).to_a.reverse.each do | num |
		result['recent_build_history'].each_pair do | key, value |
			builds = 0
			value.default= 0
			passed = value['passed'] 
			value.each_value do |v| builds= builds+v end
			if passed * 10.0 / max > num 
				string = string + color("\t||\t", :success) 
			elsif builds * 10.0 / max > num 
				string = string + color("\t||\t", :error)
			else
				string = string + "\t\t"
			end 
		end
		string = string + "\n"
	end
	result['recent_build_history'].each_pair do | key, value |
		string = string + "#{key}\t"
	end
	string = string + "\n"
	(0..maxStatuses-1).each do |statNum|
		result['recent_build_history'].each_value do |day|
			key = day.keys.at(statNum)
			if key != nil
				string = string + " #{key}: #{day[key]}\t"
			end
		end
	string = string + "\n"
	end
	say string
      end

      def eventType
        result = session.get_raw("v3/repo/#{repository.id}/overview/event_type")
        say color("statuses by event type", :info)
        info "no data" if result['event_type'].empty?
        result['event_type'].each_pair do | key, value |
          say "#{key}:"
          sum = value.reduce(0) { |s, (k, v)| s += v}
          value.each_pair do | key2, value2 |
            percentage = (value2.to_f / sum.to_f) * 100
            say "   #{key2}: #{value2} (#{percentage.round(2)}%)"
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
