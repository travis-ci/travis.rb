require 'travis/client/weak_entity'

module Travis
  module Client
    class Request < WeakEntity
      # @!parse attr_reader :commit_id, :repository_id, :created_at, :owner_id, :owner_type, :event_type, :base_commit, :head_commit, :result, :message, :pull_request, :pull_request_number, :pull_request_title, :branch, :tag
      attributes :commit_id, :repository_id, :created_at, :owner_id, :owner_type, :event_type, :base_commit, :head_commit, :result, :message, :pull_request, :pull_request_number, :pull_request_title, :branch, :tag
      time :created_at

      # @!parse attr_reader :repository
      has :repository, :commit

      one  :request
      many :requests

      def owner
        repository.owner
      end

      def accepted?
        result == 'accepted'
      end

      def rejected?
        result == 'rejected'
      end

      def inspect_info
        [
          repository && repository.slug,
          event_type, branch || pull_request_number, result
        ].compact.join(" ")
      end
    end
  end
end
