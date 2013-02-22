require 'travis/client'

module Travis
  module Client
    class Worker < Entity
      include States

      def self.cast_id(id)
        String(id)
      end

      # @!parse attr_reader :name, :host, :state, :payload
      attributes :name, :host, :state, :payload
      inspect_info :name

      one  :worker
      many :workers

      def payload=(value)
        set_attribute(:payload, session.load(value))
      end

      def repository
        payload['repo']
      end

      def job
        payload['job']
      end
    end
  end
end
