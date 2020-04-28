require 'travis/client'
require 'yaml'

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
        reply = session.post_raw("/auth/github", :github_token => github_token)
        unless reply.respond_to?(:key?) && reply.key?("access_token")
          raise InvalidTokenError, 'token is invalid, or does not have sufficient scope; see https://docs.travis-ci.com/user/github-oauth-scopes/ for more information on scope'
        end

        session.access_token = reply["access_token"]
      end

      def explicit_api_endpoint?
        @explicit_api_endpoint ||= false
      end

      def api_endpoint=(uri)
        @explicit_api_endpoint = true
        session.uri = uri
      end

      def repos(params = {})
        session.find_many(Repository, params)
      end

      def repo(id_or_slug)
        session.find_one(Repository, id_or_slug)
      end

      def build(id)
        session.find_one(Build, id)
      end

      def job(id)
        session.find_one(Job, id)
      end

      def artifact(id)
        session.find_one(Artifact, id)
      end

      alias log artifact

      def user
        session.find_one(User)
      rescue NotFound
        raise NotLoggedIn, 'currently not logged in'
      end

      def account(name)
        session.find_one(Account, name)
      end

      def accounts
        session.find_many(Account, :all => true)
      end

      def broadcasts
        session.find_many(Broadcast)
      end

      def restart(entity)
        # btw, internally we call this reset, not restart, as it resets the state machine
        # but we thought that would be too confusing
        raise Error, "cannot restart a #{entity.class.one}" unless entity.restartable?
        session.post_raw("/#{entity.class.many}/#{entity.id}/restart")
        entity.reload
      end

      def cancel(entity)
        raise Error, "cannot cancel a #{entity.class.one}" unless entity.cancelable?
        session.post_raw("/#{entity.class.many}/#{entity.id}/cancel")
        entity.reload
      end

      def logout
        session.get_raw('/logout')
      end

      def listen(*entities, &block)
        listener = Listener.new(session)
        listener.subscribe(*entities, &block)
        listener.listen
      end

      def lint(body)
        body   = body.to_yaml unless body.is_a? String
        result = session.post_raw('/lint', 'content' => body)
        LintResult.new(result)
      end

      def hooks
        session.get('hooks')['hooks']
      end
    end
  end
end
