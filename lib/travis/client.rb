require 'backports/1.9.3' if RUBY_VERSION < '1.9.3'
require 'travis/client/error'
require 'travis/client/states'
require 'travis/client/methods'
require 'travis/client/session'
require 'travis/client/entity'
require 'travis/client/user'
require 'travis/client/repository'
require 'travis/client/build'
require 'travis/client/commit'
require 'travis/client/job'
require 'travis/client/namespace'

module Travis
  module Client
    ORG_URI = 'https://api.travis-ci.org/'
    PRO_URI = 'https://api.travis-ci.com/'

    def self.new(options = {})
      options['uri'] ||= ORG_URI if options.is_a? Hash
      Session.new(options)
    end
  end
end
