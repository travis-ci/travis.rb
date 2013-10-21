require 'travis/cli'
require 'travis/tools/safe_string'
require 'travis/tools/system'

module Travis
  module CLI
    class Logs < RepoCommand
      description "streams test logs"

      def setup
        super
        check_websocket
      end

      include Tools::SafeString
      def run(number = last_build.number)
        job ||= job(number) || error("no such job ##{number}")
        info "displaying logs for #{color(job.inspect_info, [:bold, :info])}"
        job.log.body { |part| print interactive? ? encoded(part) : clean(part) }
      end

      private

        def job(number)
          number = last_build.number + number if number.start_with? '.'
          job    = super(number) || build(number) || branch(number)
          job    = job.jobs.first if job.respond_to? :jobs
          job
        end

        def check_websocket
          require 'websocket-native'
        rescue LoadError => e
          raise e if e.respond_to?(:path) and e.path != 'websocket-native'
          info "speed up log streaming by installing the websocket-native gem"
        end
    end
  end
end