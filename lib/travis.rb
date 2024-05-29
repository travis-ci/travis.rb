# frozen_string_literal: true

module Travis
  autoload :Client,   'travis/client'
  autoload :CLI,      'travis/cli'
  autoload :Pro,      'travis/pro'
  autoload :Version,  'travis/version'

  include Client::Namespace.new
end
