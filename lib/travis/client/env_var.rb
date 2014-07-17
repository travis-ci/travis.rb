require 'travis/client'
require 'delegate'

module Travis
  module Client
    class EnvVar < Entity
      class List < DelegateClass(Array)
        attr_reader :repository

        def initialize(repository, &block)
          @repository = repository
          @generator  = block || ::Proc.new { session.get(EnvVar.path(repository))['env_vars'] }
          super(nil)
        end

        def list=(list)
          __setobj__ list.dup.freeze
        end

        def __getobj__
          super || (self.list = @generator.call)
        end

        def reload
          __setobj__ nil
          self
        end

        def session
          repository.session
        end

        def repository_id
          repository.id
        end

        def add(name, value, options = {})
          body       = JSON.dump(:env_var => options.merge(:name => name, :value => value))
          result     = session.post(EnvVar.path(self), body)
          self.list += [result['env_var']]
        end

        def upsert(name, value, options = {})
          entries = select { |e| e.name == name }
          if entries.any?
            entries.first.update(options.merge(:value => value))
            entries[1..-1].each { |e| e.delete }
          else
            add(name, value, options)
          end
          reload
        end

        def [](key)
          return super if key.is_a? Integer
          detect { |e| e.name == key.to_s }
        end

        def []=(key, value)
          return super if key.is_a? Integer
          upsert(key.to_s, value)
        end

        alias list __getobj__
      end

      def self.path(object)
        repository_id = Repository === object ? object.id : object.repository_id
        raise "repository unknown" unless repository_id
        "/settings/env_vars/#{object.id if object.is_a? EnvVar}?repository_id=#{repository_id}"
      end

      include NotLoadable
      extend HasUuid
      one  :env_var
      many :env_vars

      # @!parse attr_reader :name, :public, :repository_id
      attributes :name, :value, :public, :repository_id

      # @!parse attr_reader :repository
      has :repository

      def update(options)
        options = { :value => options } unless options.is_a? Hash
        result  = session.patch(EnvVar.path(self), JSON.dump(:env_var => options))
        attributes.replace(result['env_var'].attributes)
        self
      end

      def delete
        session.delete_raw EnvVar.path(self)
        repository.env_vars.reload
        true
      end

      def inspect_info
        "#{name}=#{value ? value.inspect : "[secure]"}"
      end
    end
  end
end
