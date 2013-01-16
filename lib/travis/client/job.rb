require 'travis/client'

module Travis
  module Client
    class Job < Entity
      include States

      attributes :repository_id, :build_id, :commit_id, :log_id, :number, :config, :state, :started_at, :finished_at, :duration, :queue, :allow_failure, :tags
      time :started_at, :finished_at

      alias allow_failure? allow_failure

      has :commit, :repository, :build

      one :job
      many :jobs

      def inspect_info
        "#{repository.slug}##{number}"
      end
    end
  end
end
