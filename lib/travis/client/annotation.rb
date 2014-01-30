require 'travis/client'

module Travis
  module Client
    class Annotation < Entity
      include NotLoadable

      attributes :job_id, :provider_name, :status, :url, :description

      # @!parse attr_reader :job
      has :job

      one :annotation
      many :annotations

      def inspect_info
        "#{provider_name}: #{status}"
      end
    end
  end
end
