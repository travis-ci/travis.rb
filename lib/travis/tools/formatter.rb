require 'time'

module Travis
  module Tools
    class Formatter
      DAY         = 24 * 60 * 60
      TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
      SKIPT_KEYS  = %w[language matrix .result]

      def duration(seconds, suffix = nil)
        seconds          = (Time.now - seconds).to_i if seconds.is_a? Time
        output           = []
        minutes, seconds = seconds.divmod(60)
        hours, minutes   = minutes.divmod(60)
        output << "#{hours  } hrs" if hours > 0
        output << "#{minutes} min" if minutes > 0
        output << "#{seconds} sec" if seconds > 0 or output.empty?
        output << suffix           if suffix
        output.join(" ")
      end

      def time(time)
        #return "not yet" if time.nil? or time > Time.now
        #return duration(time, "ago") if Time.now - time < DAY
        time.localtime.strftime(TIME_FORMAT)
      end

      def job_config(config)
        output = []
        config.each_pair do |key, value|
          output << "#{key}: #{value}" unless SKIPT_KEYS.include? key
        end
        output.join(", ")
      end
    end
  end
end