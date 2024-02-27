# frozen_string_literal: true

require 'gh'

module GH
  class FakeRemote < Remote
    def setup(host, options)
      @authenticated = options[:password] == 'password'
      super
    end

    def http(*)
      raise NotImplementedError
    end

    def post(key, _body)
      raise GH::Error unless @authenticated && (key == '/authorizations')

      frontend.load('url' => 'https://api.github.com/authorizations/1', 'token' => 'github_token')
    end

    def head(*) end
    def delete(*) end
  end

  DefaultStack.replace(Remote, FakeRemote)
end
