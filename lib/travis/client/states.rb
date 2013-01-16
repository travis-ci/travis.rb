require 'travis/client'

module Travis
  module Client
    module States
      STATES = %w[created started passed failed errored canceled]

      def pending?
        check_state
        state == 'created' or state == 'started'
      end

      def started?
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
        pending? ? 'yellow' : passed? ? 'green' : 'red'
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

      alias running?    pending?
      alias successful? passed?

      private

        def check_state
          raise Error, "unknown state %p for %p" % [state, self] unless STATES.include? state
        end
    end
  end
end
