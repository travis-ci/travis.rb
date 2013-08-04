module Travis
  module Tools
    module SafeString
      extend self

      def encoded(string)
        return string unless string.respond_to? :encode
        string.encode 'utf-8'
      end

      def colorized(string)
        encoded(string).gsub(/[^[:print:]\e\n]/, '')
      end

      def clean(string)
        colorized(string).gsub(/\e[^m]+m/, '')
      end
    end
  end
end
