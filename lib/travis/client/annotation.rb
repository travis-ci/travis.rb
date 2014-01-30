require 'travis/client'

module Travis
  module Client
    class Annotation < Entity
      include NotLoadable, States
      attributes :job_id, :provider_name, :status, :url, :description
      alias state status

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
