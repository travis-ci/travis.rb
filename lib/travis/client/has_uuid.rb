module Travis
  module Client
    module HasUuid
      def id?(object)
         object =~ /\A(?:\w+-){4}\w+\Z/ if object.is_a? String
      end

      def cast_id(object)
        object.to_str
      end
    end
  end
end
