module Travis
  module Tools
    module System
      extend self

      def windows?
        File::ALT_SEPARATOR == "\\"
      end
    end
  end
end
