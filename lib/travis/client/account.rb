require 'travis/client'

module Travis
  module Client
    class Account < Entity
      attributes :name, :login, :type, :repos_count

      one :account
      many :accounts

      inspect_info :login
    end
  end
end
