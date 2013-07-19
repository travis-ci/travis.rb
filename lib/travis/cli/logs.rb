require 'travis/cli'

module Travis
  module CLI
    class Logs < RepoCommand
      def run(number = last_build.number)
        error "##{number} is not a job, try #{number}.1" unless job = job(number)
        say log(job)
      end

      private

        def log(job)
          interactive? ? job.log.colorized_body : job.log.clean_body
        end
    end
  end
end