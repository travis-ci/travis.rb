require 'travis/cli'
require 'travis/tools/safe_string'
require 'travis/tools/system'

module Travis
  module CLI
    class Logs < RepoCommand
      attr_accessor :delete, :reason
      description "streams test logs"
      on('-d', '--delete [REASON]', 'remove logs') { |c, reason| c.delete, c.reason = true, reason }
      on('-f', '--force', 'do not ask user to confirm deleting the logs')
      on('--[no-]stream', 'only print current logs, do not stream')

      def setup
        super
        check_websocket
      end

      include Tools::SafeString
      def run(number = last_build.number)
        self.stream = true if stream.nil?
        job ||= job(number) || error("no such job ##{number}")
        delete ? delete_log(job) : display_log(job)
      end

      def delete_log(job)
        unless force?
          error "not deleting logs without --force" unless interactive?
          error "aborted" unless danger_zone? "Do you really want to delete the build log for #{color(job.inspect_info, :underline)}?"
        end

        warn "deleting log for #{color(job.inspect_info, [:bold, :info])}"
        job.delete_log(reason || {})
      end

      def display_log(job)
        info "displaying logs for #{color(job.inspect_info, [:bold, :info])}"
        return print_log(job.log.body) unless stream?
        job.log.body { |part| print_log(part) }
      ensure
        print "\e[0m" if interactive?
      end

      def print_log(part)
        print interactive? ? encoded(part) : clean(part)
      end

      private

        def job(number)
          number = last_build.number + number if number.start_with? '.'
          job    = super(number) || build(number) || branch(number)
          job    = job.jobs.first if job.respond_to? :jobs
          job
        end

        def check_websocket
          require 'websocket-native' if stream?
        rescue LoadError => e
          raise e if e.respond_to?(:path) and e.path != 'websocket-native'
          info "speed up log streaming by installing the websocket-native gem"
        end
    end
  end
end