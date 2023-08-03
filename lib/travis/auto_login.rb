# frozen_string_literal: true

require 'travis'
require 'travis/client/auto_login'
Travis::Client::AutoLogin.new(Travis).authenticate
