require 'travis/pro'
require 'travis/client/auto_login'
Travis::Client::AutoLogin.new(Travis::Pro).authenticate
