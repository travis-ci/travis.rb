require 'travis/client'

module Travis
  module Client
    module States
      STATES  = %w[created queued received started passed failed errored cancelled ready]

      def ready?
        state == 'ready'
      end

      def pending?
        check_state
        %w[created started queued received ].include? state
      end

      def started?
        check_state
        state != 'created' and state != 'received' and state != 'queued'
      end

      def received?
        check_state
        state != 'created' and state != 'queued'
      end

      def queued?
        check_state
        state != 'created'
      end

      def finished?
        not pending?
      end

      def passed?
        check_state
        state == 'passed'
      end

      def errored?
        check_state
        state == 'errored'
      end

      def failed?
        check_state
        state == 'failed'
      end

      def canceled?
        check_state
        state == 'canceled'
      end

      def unsuccessful?
        errored? or failed? or canceled?
      end

      def created?
        check_state
        !!state
      end

      def color
        case state
        when 'created', 'queued', 'received', 'started' then 'yellow'
        when 'passed', 'ready'                then 'green'
        when 'errored', 'canceled', 'failed'  then 'red'
        end
      end

      def yellow?
        color == 'yellow'
      end

      def green?
        color == 'green'
      end

      def red?
        color == 'red'
      end

      def running?
        state == 'started'
      end

      alias successful? passed?

      private

        def check_state
          raise Error, "unknown state %p for %p" % [state, self] unless STATES.include? state
        end
    end
  end
end
