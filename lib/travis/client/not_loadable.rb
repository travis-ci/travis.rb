module Travis
  module Client
    module NotLoadable
      def missing?(attribute)
        false
      end

      def complete?
        true
      end
    end
  end
end
