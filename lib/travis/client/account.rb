require 'travis/client'

module Travis
  module Client
    class Account < Entity
      attributes :name, :login, :type, :repos_count, :subscribed

      one :account
      many :accounts

      inspect_info :login

      def subscribed
        attributes.fetch('subscribed') { true }
      end
    end
  end
end
