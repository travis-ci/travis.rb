require 'travis/client'

module Travis
  module Client
    class Build < Entity
      include States

      # @!parse attr_reader :repository_id, :commit_id, :number, :pull_request, :config, :state, :started_at, :finished_at, :duration, :job_ids
      attributes :repository_id, :commit_id, :number, :pull_request, :config, :state, :started_at, :finished_at, :duration, :job_ids
      time :started_at, :finished_at

      alias pull_request? pull_request

      # @!parse attr_reader :repository, :commit, :jobs
      has :repository, :commit, :jobs

      one :build
      many :builds
      aka :branches

      def restart
        session.restart(self)
      end

      def push?
        not pull_request?
      end

      def pr_number
        commit.compare_url[/\d+$/] if pull_request?
      end

      def branch_info
        pull_request? ? "Pull Request ##{pr_number}" : commit.branch
      end

      def inspect_info
        "#{repository.slug}##{number}"
      end
    end
  end
end
