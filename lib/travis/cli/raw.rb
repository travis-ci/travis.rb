require 'travis/cli'
require 'pp'

module Travis
  module CLI
    class Raw < ApiCommand
      skip :authenticate
      on('--[no-]json', 'display as json')

      def run(resource)
        reply = session.get_raw(resource)
        json? ? say(reply.to_json) : pp(reply)
      end
    end
  end
end
