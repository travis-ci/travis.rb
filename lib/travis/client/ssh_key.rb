require 'json'

module Travis
  module Client
    class SshKey < SingletonSetting
      attributes :description, :fingerprint
      one        :ssh_key
      many       :ssh_keys
    end
  end
end
