require 'travis/cli'

module Travis
  module CLI
    class Endpoint < ApiCommand
      description "displays or changes the API endpoint"

      skip :authenticate
      on '--drop-default', 'delete stored default endpoint'
      on '--set-default', 'store endpoint as global default'
      on '--github', 'display github endpoint'

      def run_github
        error "--github cannot be combined with --drop-default" if drop_default?
        error "--github cannot be combined with --set-default" if set_default?
        load_gh
        say github_endpoint.to_s, "GitHub endpoint: %s"
      end

      def run_travis
        if drop_default? and was = config['default_endpoint']
          config.delete('default_endpoint')
          say was, "default API endpoint dropped (was %s)"
        else
          config['default_endpoint'] = api_endpoint if set_default?
          say api_endpoint, "API endpoint: %s#{" (stored as default)" if set_default?}"
        end
      end

      def run
        github? ? run_github : run_travis
      end
    end
  end
end
