require 'travis/client'

module Travis
  module Client
    module Methods
      def access_token
        session.access_token
      end

      def access_token=(token)
        session.access_token = token
      end

      def api_endpoint
        session.uri
      end

      def github_auth(github_token)
        reply = session.post_raw("/auth/github?github_token=#{github_token}")
        session.access_token = reply["access_token"]
      end

      def api_endpoint=(uri)
        session.uri = uri
      end

      def repos(params = {})
        session.find_many(Repository, params)
      end

      def repo(id_or_slug)
        session.find_one(Repository, id_or_slug)
      end

      def user
        session.find_one(User)
      end
    end
  end
end