# frozen_string_literal: true

module Travis
  module Tools
    module SafeString
      module_function

      def encoded(string)
        return string unless string.respond_to? :encode

        string.encode 'utf-8'
      rescue Encoding::UndefinedConversionError
        string.force_encoding 'utf-8'
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
