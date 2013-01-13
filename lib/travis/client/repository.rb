require 'travis/client'
require 'openssl'
require 'base64'

module Travis
  module Client
    class Repository < Entity
      class Key
        attr_reader :to_s

        def initialize(data)
          @to_s = data
        end

        def encrypt(value)
          encrypted = to_rsa.public_encrypt(value)
          Base64.encode64(encrypted).strip
        end

        def to_rsa
          @to_rsa ||= OpenSSL::PKey::RSA.new(to_s)
        rescue OpenSSL::PKey::RSAError
          public_key = to_s.gsub('RSA PUBLIC KEY', 'PUBLIC KEY')
          @to_rsa = OpenSSL::PKey::RSA.new(public_key)
        end

        def ==(other)
          other.to_s == self
        end
      end

      attributes :slug, :description, :last_build_id, :last_build_number, :last_build_state, :last_build_duration, :last_build_language, :last_build_started_at, :last_build_finished_at
      inspect_info :slug

      one  :repo
      many :repos

      def public_key
        attributes["public_key"] ||= begin
          payload = session.get_raw("/repos/#{id}/key")
          Key.new(payload.fetch('key'))
        end
      end

      def public_key=(key)
        key = Key.new(key) unless key.is_a? Key
        set_attribute(:public_key, key)
      end

      alias key  public_key
      alias key= public_key=

      def encrypt(value)
        key.encrypt(value)
      end

      def last_build_started_at=(time)
        set_attribute(:last_build_started_at, time(time))
      end

      def last_build_finished_at=(time)
        set_attribute(:last_build_finished_at, time(time))
      end
    end
  end
end
