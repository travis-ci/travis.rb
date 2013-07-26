require 'travis/client'

module Travis
  module Client
    class Broadcast < Entity
      attributes :recipient_id, :recipient_type, :kind, :message, :expired, :created_at, :updated_at

      one :broadcast
      many :broadcasts

      inspect_info :message
    end
  end
end
