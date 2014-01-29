require 'travis/client'

module Travis
  module Client
    class Annotation < Entity
      attributes :job_id, :provider_name, :status, :url, :description

      # @!parse attr_reader :job
      has :job

      one :annotation
      many :annotations
    end
  end
end
