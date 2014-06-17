module Travis
  module Client
    class LintResult
      Warning = Struct.new(:key, :message)
      attr_accessor :warnings

      def initialize(payload)
        @warnings = []
        payload   = payload['lint'] if payload['lint']

        Array(payload['warnings']).each do |warning|
          @warnings << Warning.new(warning['key'], warning['message'])
        end
      end

      def warnings?
        warnings.any?
      end

      def ok?
        !warnings?
      end
    end
  end
end
