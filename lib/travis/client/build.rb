require 'travis/client'

module Travis
  module Client
    class Build < Entity
      include States, Restartable
      preloadable

      # @!parse attr_reader :repository_id, :commit_id, :number, :pull_request, :pull_request_number, :pull_request_title, :config, :state, :started_at, :finished_at, :duration, :job_ids
      attributes :repository_id, :commit_id, :number, :pull_request, :pull_request_number, :pull_request_title, :config, :state, :started_at, :finished_at, :duration, :job_ids
      time :started_at, :finished_at

      alias pull_request? pull_request
      alias pr_number pull_request_number

      # @!parse attr_reader :repository, :commit, :jobs
      has :repository, :commit, :jobs

      one :build
      many :builds
      aka :branch, :branches

      def push?
        not pull_request?
      end

      def branch_info
        info = commit.branch
        pull_request? ? info + " (PR ##{pr_number})" : info
      end

      def pusher_channels
        repository.pusher_channels
      end

      def inspect_info
        "#{repository.slug}##{number}"
      end
    end
  end
end
