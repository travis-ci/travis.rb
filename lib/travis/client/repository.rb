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

      include States

      attributes :slug, :description, :last_build_id, :last_build_number, :last_build_state, :last_build_duration, :last_build_started_at, :last_build_finished_at
      inspect_info :slug

      time :last_build_finished_at, :last_build_started_at

      one  :repo
      many :repos
      aka  :repository

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

      def last_build
        attributes['last_build'] ||= begin
          last_build               = session.find_one(Build, last_build_id)
          last_build.number        = last_build_number
          last_build.state         = last_build_state
          last_build.duration      = last_build_duration
          last_build.started_at    = last_build_started_at
          last_build.finished_at   = last_build_finished_at
          last_build.repository_id = id
          last_build
        end
      end

      def builds(params = nil)
        return each_build unless params
        session.find_many(Build, params.merge(:repository_id => id))
      end

      def build(number)
        builds(number: number.to_s).first
      end

      def recent_builds
        builds({})
      end

      def each_build(params = {}, &block)
        return enum_for(__method__, params) unless block_given?
        chunk = recent_builds
        until chunk.empty?
          chunk.each(&block)
          number = chunk.last.number
          chunk  = number == '1' ? [] : builds(params.merge(:after_number => number))
        end
        self
      end

      private

        def state
          last_build_state
        end
    end
  end
end
