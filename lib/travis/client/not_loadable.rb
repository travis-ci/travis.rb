# frozen_string_literal: true

module Travis
  module Client
    module NotLoadable
      def missing?(_attribute)
        false
      end

      def complete?
        true
      end
    end
  end
end
