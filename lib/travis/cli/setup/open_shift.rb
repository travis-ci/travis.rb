require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class OpenShift < Service
        description "automatic deployment to OpenShfit"

        def run
          deploy 'openshift' do |config|
            config['user']     = ask("OpenShift user: ").to_s
            config['password'] = ask("OpenShift password: ") { |q| q.echo = "*" }.to_s
            config['app']      = ask("OpenShift application name: ") { |q| q.default = repository.name }.to_s
            config['domain']   = ask("OpenShift domain: ").to_s
          end
        end
      end
    end
  end
end