require 'travis/cli'
require 'travis/tools/safe_string'

module Travis
  module CLI
    class Logs < RepoCommand
      include Tools::SafeString
      def run(number = last_build.number)
        error "##{number} is not a job, try #{number}.1" unless job = job(number)
        job.log.body { |part| print interactive? ? encoded(part) : clean(part) }
      end
    end
  end
end