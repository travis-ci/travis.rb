require 'travis/client/weak_entity'

module Travis
  module Client
    class Cache < WeakEntity
      # @!parse attr_reader :repository_id, :size, :slug, :branch, :last_modified
      attributes :repository_id, :size, :slug, :branch, :last_modified
      time :last_modified

      # @!parse attr_reader :repository
      has :repository

      one :cache
      many :caches

      def delete
        repository.delete_caches(:branch => branch, :match => slug)
      end

      def inspect_info
        [repository.slug, branch, slug].compact.join(" ")
      end
    end
  end
end
