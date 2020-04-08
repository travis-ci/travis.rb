require 'openssl'
require 'base64'

module Travis
  module Tools
    module SSLKey
      extend self

      def generate_rsa(size = 2048)
        OpenSSL::PKey::RSA.generate(size)
      end

      def public_rsa_key(string)
        @to_rsa ||= OpenSSL::PKey::RSA.new(string)
      rescue OpenSSL::PKey::RSAError
        public_key = string.gsub('RSA PUBLIC KEY', 'PUBLIC KEY')
        @to_rsa = OpenSSL::PKey::RSA.new(public_key)
      end

      def has_passphrase?(key)
        OpenSSL::PKey::RSA.new(key, key[0..1023])
        false
      rescue OpenSSL::OpenSSLError
        true
      end

      def remove_passphrase(key, passphrase)
        OpenSSL::PKey::RSA.new(key, passphrase).to_s
      rescue OpenSSL::PKey::RSAError
        false
      end

      def rsa_ssh(key)
        ['ssh-rsa ', "\0\0\0\assh-rsa#{sized_bytes(key.e)}#{sized_bytes(key.n)}"].pack('a*m').gsub("\n", '')
      end

      def sized_bytes(value)
        bytes = to_byte_array(value.to_i)
        [bytes.size, *bytes].pack('NC*')
      end

      def to_byte_array(num, *significant)
        return significant if num.between?(-1, 0) and significant[0][7] == num[7]
        to_byte_array(*num.divmod(256)) + significant
      end
    end
  end
end
