# frozen_string_literal: true

require 'travis/client/error'
require 'travis/client/states'
require 'travis/client/restartable'
require 'travis/client/not_loadable'
require 'travis/client/has_uuid'
require 'travis/client/methods'
require 'travis/client/session'
require 'travis/client/entity'
require 'travis/client/user'
require 'travis/client/repository'
require 'travis/client/env_var'
require 'travis/client/build'
require 'travis/client/artifact'
require 'travis/client/cache'
require 'travis/client/commit'
require 'travis/client/job'
require 'travis/client/namespace'
require 'travis/client/account'
require 'travis/client/broadcast'
require 'travis/client/settings'
require 'travis/client/singleton_setting'
require 'travis/client/ssh_key'
require 'travis/client/request'
require 'travis/client/listener'
require 'travis/client/lint_result'

module Travis
  module Client

    COM_URI = 'https://api.travis-ci.com/'

    def self.new(options = {})
      options[:uri] ||= COM_URI if options.is_a?(Hash) && !(options['uri'])
      Session.new(options)
    end
  end
end
