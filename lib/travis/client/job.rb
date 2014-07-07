require 'travis/client'

module Travis
  module Client
    class Job < Entity
      include States, Restartable
      preloadable

      # @!parse attr_reader :repository_id, :build_id, :commit_id, :log_id, :number, :config, :state, :started_at, :finished_at, :queue, :allow_failure, :tags
      attributes :repository_id, :build_id, :commit_id, :log_id, :number, :config, :state, :started_at, :finished_at, :queue, :allow_failure, :tags, :annotation_ids
      time :started_at, :finished_at

      alias allow_failure? allow_failure

      # @!parse attr_reader :commit, :repository, :build, :annotations
      has :commit, :repository, :build, :log, :annotations

      one :job
      many :jobs

      def pull_request?
        build.pull_request?
      end

      def push?
        build.push?
      end

      def branch_info
        build.branch_info
      end

      def allow_failures?
        return false unless config.include? 'matrix' and config['matrix'].include? 'allow_failures'
        config['matrix']['allow_failures'].any? do |allow|
          allow.all? { |key, value| config[key] == value }
        end
      end

      def duration
        attributes['duration'] ||= begin
          start  = started_at  || Time.now
          finish = finished_at || Time.now
          (finish - start).to_i
        end
      end

      def delete_log(reason = {})
        log.delete_body(reason)
      end

      def pusher_channels
        build.pusher_channels + ["job-#{id}"]
      end

      def inspect_info
        "#{repository.slug}##{number}"
      end
    end
  end
end
