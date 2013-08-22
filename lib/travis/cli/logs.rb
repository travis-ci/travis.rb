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
        error "##{number} is not a job, try #{number}.1" unless job = job(number)
        job.log.body { |part| print interactive? ? encoded(part) : clean(part) }
      end

      private

        def check_websocket
          require 'websocket-native'
        rescue LoadError => e
          raise e if e.respond_to?(:path) and e.path != 'websocket-native'
          info "speed up log streaming by installing the websocket-native gem"
        end
    end
  end
end