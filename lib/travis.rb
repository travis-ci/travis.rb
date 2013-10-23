module Travis
  autoload :Client,   'travis/client'
  autoload :CLI,      'travis/cli'
  autoload :Pro,      'travis/pro'
  autoload :Version,  'travis/version'

  include Client::Namespace.new(Client::ORG_URI)

  Basedir = File.expand_path File.join File.dirname(__FILE__), '../'
end
