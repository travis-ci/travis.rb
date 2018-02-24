require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class BluemixCloudFoundry < Service
        description "automatic deployment to Bluemix Cloud Foundry"

        def run
          deploy 'bluemixcloudfoundry' do |config|
            config['username']     ||= ask("Bluemix username: ").to_s
            config['password']     ||= ask("Bluemix password: ") { |q| q.echo = "*" }.to_s
            config['organization'] ||= ask("Bluemix organization: ").to_s
            config['space']        ||= ask("Bluemix space: ").to_s
            config['region']       ||= ask("Bluemix region [ng, eu-gb, au-syd]: ") { |q| q.default = "ng" }
          end
        end
      end
    end
  end
end
