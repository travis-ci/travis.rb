require 'travis/cli'

module Travis
  module CLI
    class Endpoint < ApiCommand
      description "displays or changes the API endpoint"

      skip :authenticate
      on '--drop-default', 'delete stored default endpoint'
      on '--set-default', 'store endpoint as global default'

      def run
        if drop_default? and was = config['default_endpoint']
          config.delete('default_endpoint')
          say was, "default API endpoint dropped (was %s)"
        else
          config['default_endpoint'] = api_endpoint if set_default?
          say api_endpoint, "API endpoint: %s#{" (stored as default)" if set_default?}"
        end
      end
    end
  end
end
