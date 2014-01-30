require 'travis/client'

module Travis
  module Client
    class Commit < Entity
      include NotLoadable

      # @!parse attr_reader :sha, :branch, :message, :committed_at, :author_name, :author_email, :committer_name, :committer_email, :compare_url
      attributes :sha, :branch, :message, :committed_at, :author_name, :author_email, :committer_name, :committer_email, :compare_url
      time :committed_at

      one :commit
      many :commits

      def subject
        message.to_s.lines.first.to_s.strip
      end

      def short_sha
        sha.to_s[0..6]
      end

      def inspect_info
        short_sha + " " + subject.inspect
      end
    end
  end
end
