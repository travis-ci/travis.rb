require 'travis/client'

module Travis
  module Client
    class Namespace < Module
      class Curry < Module
        attr_accessor :namespace, :type

        def initialize(namespace, type)
          @namespace, @type = namespace, type
        end

        def find_one(id = nil)
          result = session.find_one(type, id)
          result.curry = self
          result
        end

        def current
          result = session.find_one_or_many(type)
          Array(result).each { |e| e.curry = self }
          result
        end

        def find_many(params = {})
          session.find_many(type, params).each do |entity|
            entity.curry = self
          end
        end

        alias find     find_one
        alias find_all find_many

        def clear_cache
          session.clear_cache
        end

        def clear_cache!
          session.clear_cache!
        end

        private

          def session
            namespace.session
          end
      end

      include Methods
      attr_accessor :session

      def initialize(session = nil)
        session  = Travis::Client.new(session || {}) unless session.is_a? Session
        @session = session

        Entity.subclasses.each do |subclass|
          name = subclass.name[/[^:]+$/]
          const_set(name, Curry.new(self, subclass))
        end
      end

      def included(klass)
        fix_names(klass)
        delegate_session(klass)
      end

      private

        def fix_names(klass)
          constants.each do |name|
            const = klass.const_get(name)
            klass.const_set(name, const) if const == const_get(name)
          end
        end

        def delegate_session(klass)
          return if klass == Object or klass == Kernel
          klass.extend(Methods)
          namespace = self
          klass.define_singleton_method(:session)  { namespace.session }
          klass.define_singleton_method(:session=) { |value| namespace.session = value }
        end
    end
  end
end
