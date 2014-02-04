require 'travis/client'

module Travis
  module Client
    class User < Entity
      # @!parse attr_reader :login, :name, :email, :gravatar_id, :locale, :is_syncing, :synced_at, :correct_scopes
      attributes :login, :name, :email, :gravatar_id, :locale, :is_syncing, :synced_at, :correct_scopes, :channels
      inspect_info :login

      one  :user
      many :users

      def synced_at=(time)
        set_attribute(:synced_at, time(time))
      end

      def sync
        session.post_raw('/users/sync')
        reload
      end

      def channels
        load_attribute(:is_syncing) # dummy to trigger load, as channels might not be included
        attributes['channels'] ||= ['common']
      end

      def permissions
        attributes['permissions'] ||= begin
          repos = session.get('/users/permissions')
          repos.each_value { |r| r.compact! }
          repos
        end
      end

      def repositories
        permissions['permissions']
      end

      def push_access
        permissions['push']
      end

      def pull_access
        permissions['pull']
      end

      def admin_access
        permissions['admin']
      end

      def push_access?(repo)
        push_access.include? repo
      end

      def pull_access?(repo)
        pull_access.include? repo
      end

      def admin_access?(repo)
        admin_access.include? repo
      end

      alias syncing? is_syncing
      alias correct_scopes? correct_scopes
    end
  end
end
