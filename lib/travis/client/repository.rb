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
          Base64.encode64(encrypted).gsub(/\s+/, "")
        end

        def to_ssh
          ['ssh-rsa ', "\0\0\0\assh-rsa#{sized_bytes(to_rsa.e)}#{sized_bytes(to_rsa.n)}"].pack('a*m').gsub("\n", '')
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

        private

          def sized_bytes(value)
            bytes = to_byte_array(value.to_i)
            [bytes.size, *bytes].pack('NC*')
          end

          def to_byte_array(num, *significant)
            return significant if num.between?(-1, 0) and significant[0][7] == num[7]
            to_byte_array(*num.divmod(256)) + significant
          end
      end

      include States
      preloadable

      # @!parse attr_reader :slug, :description
      attributes :slug, :active, :private, :admin, :description, :last_build_id, :last_build_number, :last_build_state, :last_build_duration, :last_build_started_at, :last_build_finished_at, :github_language
      inspect_info :slug

      time :last_build_finished_at, :last_build_started_at

      one  :repo
      many :repos
      aka  :repository, :permissions, :admin, :pull, :push, :hooks

      def initialize(*)
        super
        attributes['active'] = attributes['private'] = attributes['admin'] = nil
      end

      def public_key
        attributes["public_key"] ||= begin
          payload = session.get_raw("/repos/#{id}/key")
          Key.new(payload.fetch('key'))
        end
      end

      def name
        slug[/[^\/]+$/]
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

      # @!parse attr_reader :last_build
      def last_build
        return unless last_build_id
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
        builds(:number => number.to_s).first
      end

      def recent_builds
        builds({})
      end

      def last_on_branch(name = nil)
        return branch(name) if name
        attributes['last_on_branch'] ||= session.get('branches', :repository_id => id)['branches']
      end

      def branches
        last_on_branch.map { |b| { b.commit.branch => b } }.inject(:merge)
      end

      def branch(name)
        attributes['branches']       ||= {}
        attributes['branches'][name] ||= begin
          build = attributes['last_on_branch'].detect { |b| b.commit.branch == name.to_s } if attributes['last_on_branch']
          build || session.get("/repos/#{id}/branches/#{name}")['branch']
        end
      end

      def each_build(params = nil, &block)
        return enum_for(__method__, params) unless block_given?
        params ||= {}
        chunk = builds(params)
        until chunk.empty?
          chunk.each(&block)
          number = chunk.last.number
          chunk  = number == '1' ? [] : builds(params.merge(:after_number => number))
        end
        self
      end

      def job(number)
        build_number = number.to_s[/^\d+/] or return nil
        build        = build(build_number) or return nil
        job          = build.jobs.detect { |j| j.number == number } if number != build_number
        job        ||= build.jobs.first if build and build.jobs.size == 1
        job
      end

      def set_hook(flag)
        result = session.put_raw('/hooks/', :hook => { :id => id, :active => flag })
        result['result']
      end

      def disable
        set_hook(false)
      end

      def enable
        set_hook(true)
      end

      def pusher_channels
        attributes['pusher_channels'] ||= if session.private_channels?
          ["user-#{session.user.id}", "repo-#{id}"]
        else
          ["common"]
        end
      end

      def member?
        session.user.repositories.include? self
      end

      def owner_name
        slug[/^[^\/]+/]
      end

      def owner
        session.account(owner_name)
      end

      def requests
        attributes['requests'] ||= session.find_many(Request, :repository_id => id)
      end

      def settings
        attributes['settings'] ||= begin
          settings = session.get("/repos/#{id}/settings")['settings']
          settings.repository = self
          settings
        end
      rescue Travis::Client::NotFound
        raise Travis::Client::Error, "not allowed to access settings"
      end

      def caches(params = {})
        session.get("/repos/#{id}/caches", params)['caches']
      end

      def delete_caches(params = {})
        session.delete("/repos/#{id}/caches", params)['caches']
      end

      def active?
        # TODO remove once active is properly synced and exposed by api
        return active unless active.nil?
        last_build_id?
      end

      def admin?(user = session.user)
        user.admin_access? self
      end

      def push?(user = session.user)
        user.push_access? self
      end

      def pull?(user = session.user)
        user.pull_access? self
      end

      private

        def state
          last_build_state
        end
    end
  end
end
