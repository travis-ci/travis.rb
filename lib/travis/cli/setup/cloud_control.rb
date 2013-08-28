require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class CloudControl < Service
        description "automatic deployment to cloudControl"

        def run
          deploy 'cloudcontrol' do |config|
            config['email']      = ask("cloudControl email: ").to_s
            config['password']   = ask("cloudControl password: ") { |q| q.echo = "*" }.to_s
            app                  = ask("cloudControl application: ") { |q| q.default = repository.name }.to_s
            dep                  = ask("cloudControl deployment: ") { |q| q.default = "default" }.to_s
            config['deployment'] = "#{app}/#{dep}"
          end
        end
      end
    end
  end
end