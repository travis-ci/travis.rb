require 'travis/cli'
require 'pp'

module Travis
  module CLI
    class Raw < ApiCommand
      description "makes an (authenticated) API call and prints out the result"

      skip :authenticate
      on('--[no-]json', 'display as json')

      def run(resource)
        reply = session.get_raw(resource)
        json? ? say(reply.to_json) : pp(reply)
      rescue Travis::Client::NotFound
        error "resource not found"
      end
    end
  end
end
