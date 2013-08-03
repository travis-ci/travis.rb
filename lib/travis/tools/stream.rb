require 'pusher-client'

module Travis
  module Tools
    class Stream
      attr_accessor :socket
      PUSHER_KEY = "5df8ac576dcccf4fd076"
      JOB_PREFIX = "job-"

      def initialize(api_key=nil)
        api_key ||= PUSHER_KEY
        PusherClient.logger.level = Logger::ERROR
        @socket = PusherClient::Socket.new(api_key)
      end

      def on_data(p)
        @receive = p
      end

      def on_finished(p)
        @finished = p
      end

      def subscribe(id)
        @socket["#{JOB_PREFIX}#{id}"].bind('job:log') do |data|
          @receive.call(data)
        end

        @socket["#{JOB_PREFIX}#{id}"].bind('job:finished') do |data|
          @finished.call(data)
          @socket.unsubscribe("#{JOB_PREFIX}#{id}")
        end

        @socket.subscribe("#{JOB_PREFIX}#{id}")
        @socket.connect(async=true)
      end
    end
  end
end
