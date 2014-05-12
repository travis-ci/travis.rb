require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Cloud_66 < Service
        description "Automatic deployment to Cloud 66"
        service_name 'cloud66'

        def run
          deploy 'cloud66', 'release' do |config|
            config['redeployment_hook'] ||= ask("Cloud 66 Redeployment Hook Url: ") { |q| q.echo = "*" }.to_s

            encrypt(config, 'redeployment_hook') if agree("Encrypt Redeployment Hook?") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end