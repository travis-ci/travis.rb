require 'travis/client/session'
require 'travis/client/user'
require 'travis/client/repository'
require 'travis/client/namespace'

module Travis
  module Client
    ORG_URI = 'https://api.travis-ci.org'
    PRO_URI = 'https://api.travis-ci.com'

    def self.new(options = {})
      options['uri'] ||= ORG_URI if options.is_a? Hash
      Session.new(options)
    end
  end
end
