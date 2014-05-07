require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Ninefold < Service
        description "Automatic deployment to Ninefold"

        def run
          deploy 'ninefold', 'release' do |config|
            config['app_id']     ||= ask("Ninefold App ID: ").to_s
            config['auth_token'] ||= ask("Ninefold Auth Token: ") { |q| q.echo = "*" }.to_s

            encrypt(config, 'auth_token') if agree("Encrypt Auth Token? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end