require 'travis/client/weak_entity'
require 'json'

module Travis
  module Client
    class Settings < WeakEntity
      attr_accessor :repository
      # @!parse attr_reader :builds_only_with_travis_yml, :build_pushes, :build_pull_requests
      attributes :builds_only_with_travis_yml, :build_pushes, :build_pull_requests
      one :settings
      many :settings

      def save
        raise "repository unknown" unless repository
        result = session.patch("/repos/#{repository.id}/settings", JSON.dump("settings" => attributes))
        attributes.replace(result['settings'].attributes)
        self
      end

      def inspect_info
        repository ? repository.slug : repository
      end
    end
  end
end
