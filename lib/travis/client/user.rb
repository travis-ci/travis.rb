require 'travis/client/entity'

module Travis
  module Client
    class User < Entity
      attributes :login, :name, :email, :gravatar_id, :locale, :is_syncing, :synced_at, :correct_scopes
      inspect_info :login

      one  :user
      many :users

      def synced_at=(time)
        set_attribute(:synced_at, time(time))
      end
    end
  end
end
