# frozen_string_literal: true

require 'travis/client'

module Travis
  Pro = Client::Namespace.new(Client::COM_URI)
end
