require 'travis/client'

module Travis
  module Client
    class Job < Entity
      include States

      # @!parse attr_reader :repository_id, :build_id, :commit_id, :log_id, :number, :config, :state, :started_at, :finished_at, :duration, :queue, :allow_failure, :tags
      attributes :repository_id, :build_id, :commit_id, :log_id, :number, :config, :state, :started_at, :finished_at, :duration, :queue, :allow_failure, :tags
      time :started_at, :finished_at

      alias allow_failure? allow_failure

      # @!parse attr_reader :commit, :repository, :build
      has :commit, :repository, :build

      one :job
      many :jobs

      def inspect_info
        "#{repository.slug}##{number}"
      end
    end
  end
end
