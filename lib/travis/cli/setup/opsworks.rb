require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class OpsWorks < Service
        description "deployment to OpsWorks"

        def run
          deploy 'opsworks' do |config|
            config['access_key_id'] = ask("Access key ID: ").to_s
            config['secret_access_key'] = ask("Secret access key: ") { |q| q.echo = "*" }.to_s
            config['app-id'] = ask("App ID: ").to_s
            config['migrate'] = true if agree("Migrate the Database? ") { |q| q.default = 'no' }

            encrypt(config, 'secret_access_key') if agree("Encrypt secret access key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end