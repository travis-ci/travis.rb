module Travis
  autoload :Client,   'travis/client'
  autoload :CLI,      'travis/cli'
  autoload :Pro,      'travis/pro'
  autoload :Version,  'travis/version'

  include Client::Namespace.new(Client::ORG_URI)
end
