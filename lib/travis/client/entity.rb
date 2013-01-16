require 'travis/client'
require 'time'

module Travis
  module Client
    class Entity
      attr_reader :attributes, :id, :session
      attr_accessor :curry

      MAP = {}

      def self.subclasses
        MAP.values.uniq
      end

      def self.subclass_for(key)
        MAP.fetch(key)
      end

      def self.aka(name)
        MAP[name.to_s] = self
      end

      def self.one(key = nil)
        MAP[key.to_s] = self if key
        @one ||= key.to_s
      end

      def self.many(key = nil)
        MAP[key.to_s] = self if key
        @many ||= key.to_s
      end

      def self.attributes(*list)
        @attributes ||= []
        list.each do |name|
          name = name.to_s
          @attributes << name
          define_method(name) { load_attribute(name) }
          define_method("#{name}=") { |value| set_attribute(name, value) }
          define_method("#{name}?") { !!send(name) }
        end
        @attributes
      end

      def self.time(*list)
        list.each do |name|
          define_method("#{name}=") { |value| set_attribute(name, time(value)) }
        end
      end

      def self.has(*list)
        list.each do |name|
          define_method(name) { relation(name.to_s) }
        end
      end

      def self.inspect_info(name)
        alias_method(:inspect_info, name)
        private(:inspect_info)
      end

      def initialize(session, id)
        @attributes = {}
        @session    = session
        @id         = Integer(id)
      end

      def update_attributes(data)
        data.each_pair do |key, value|
          self[key] = value
        end
      end

      def attribute_names
        self.class.attributes
      end

      def [](key)
        send(key) if include? key
      end

      def []=(key, value)
        send("#{key}=", value) if include? key
      end

      def include?(key)
        attributes.include? key or attribute_names.include? key.to_s
      end

      def reload
        session.reload(self)
      end

      def load
        reload unless complete?
      end

      def missing?(key)
        return false unless include? key
        !attributes.include?(key.to_s)
      end

      def complete?
        attribute_names.all? { |key| attributes.include? key }
      end

      def inspect
        klass = self.class
        klass = curry if curry and curry.name and curry.to_s.size < klass.to_s.size
        "#<#{klass}: #{inspect_info}>"
      end

      private

        def relation(name)
          name   = name.to_s
          entity = Entity.subclass_for(name)

          if entity.many == name
            send("#{entity.one}_ids").map do |id|
              session.find_one(entity, id)
            end
          else
            session.find_one(entity, send("#{name}_id"))
          end
        end

        def inspect_info
          id
        end

        def set_attribute(name, value)
          attributes[name.to_s] = value
        end

        def load_attribute(name)
          reload if missing? name
          attributes[name.to_s]
        end

        # shamelessly stolen from sinatra
        def time(value)
          if value.respond_to? :to_time
            value.to_time
          elsif value.is_a? Time
            value
          elsif value.respond_to? :new_offset
            d = value.new_offset 0
            t = Time.utc d.year, d.mon, d.mday, d.hour, d.min, d.sec + d.sec_fraction
            t.getlocal
          elsif value.respond_to? :mday
            Time.local(value.year, value.mon, value.mday)
          elsif value.is_a? Numeric
            Time.at value
          elsif value.nil? or value.empty?
            nil
          else
            Time.parse value.to_s
          end
        rescue ArgumentError => boom
          raise boom
        rescue Exception
          raise ArgumentError, "unable to convert #{value.inspect} to a Time object"
        end
    end
  end
end
