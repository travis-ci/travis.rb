require 'travis/client'

module Travis
  module Client
    class WeakEntity < Entity
      include NotLoadable

      def self.weak?
        true
      end

      def self.id_field
        raise "weak entities do not have id fields"
      end

      def self.id?(object)
        object.nil?
      end

      def self.cast_id(object)
        return object if id? object
        raise "weak entities do not have id fields"
      end
    end
  end
end