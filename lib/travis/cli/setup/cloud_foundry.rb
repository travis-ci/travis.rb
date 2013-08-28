require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class CloudFoundry < Service
        description "automatic deployment to Cloud Foundry"

        def run
          configure 'deploy', 'provider' => 'cloudfoundry' do |config|
            config['target']       = ask("Cloud Foundry target: ").to_s
            config['username']     = ask("Cloud Foundry user name: ").to_s
            config['password']     = ask("Cloud Foundry password: ") { |q| q.echo = "*" }.to_s
            config['organization'] = ask("Cloud Foundry organization: ").to_s
            config['space']        = ask("Cloud Foundry space: ").to_s
            config['on']           = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
            encrypt(config, 'password') if agree("Encrypt password? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end