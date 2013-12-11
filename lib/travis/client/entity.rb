require 'travis/client'
require 'time'

module Travis
  module Client
    class Entity
      attr_reader :attributes, :id, :session
      attr_accessor :curry

      MAP = {}

      def self.relations
        @relations ||= []
      end

      def self.subclasses
        MAP.values.uniq
      end

      def self.subclass_for(key)
        MAP.fetch(key.to_s)
      end

      def self.aka(*names)
        names.each { |n| MAP[n.to_s] = self }
      end

      def self.weak?
        false
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
          fail "can't call an attribute id" if name == "id"

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
          relations << name
          define_method(name) { relation(name.to_s) }
        end
      end

      def self.inspect_info(name)
        alias_method(:inspect_info, name)
        private(:inspect_info)
      end

      def self.cast_id(id)
        Integer(id)
      end

      def self.id?(object)
        object.is_a? Integer
      end

      def self.id_field(key = nil)
        @id_field = key.to_s if key
        @id_field || superclass.id_field
      end

      def self.preloadable
        def self.preloadable?
          true
        end
      end

      def self.preloadable?
        false
      end

      id_field :id

      def initialize(session, id)
        raise Travis::Client::Error, '%p is not a valid id' % id unless self.class.id? id
        @attributes = {}
        @session    = session
        @id         = self.class.cast_id(id) if id
      end

      def update_attributes(data)
        data.each_pair do |key, value|
          self[key] = value
        end
      end

      def attribute_names
        self.class.attributes
      end

      def to_h
        Hash[attribute_names.map { |n| [n, self[n]] }]
      end

      def [](key)
        key = key.to_s
        send(key) if include? key
      end

      def []=(key, value)
        key = key.to_s
        send("#{key}=", value) if include? key
      end

      def include?(key)
        attributes.include? key or attribute_names.include? key.to_s
      end

      def reload
        relations.each { |e| session.reset(e) }
        session.reset(self)
      end

      def load
        session.reload(self) unless complete?
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

      def relations
        self.class.relations.map { |r| public_send(r) }.flatten(1)
      end

      def restartable?
        false
      end

      def cancelable?
        false
      end

      private

        def relation(name)
          name   = name.to_s
          entity = Entity.subclass_for(name)

          if entity.many == name
            Array(send("#{entity.one}_ids")).map do |id|
              session.find_one(entity, id)
            end
          else
            id = send("#{name}_id")
            session.find_one(entity, id) unless id.nil?
          end
        end

        def inspect_info
          id
        end

        def set_attribute(name, value)
          attributes[name.to_s] = value
        end

        def load_attribute(name)
          session.reload(self) if missing? name
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
