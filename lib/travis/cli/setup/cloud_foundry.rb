require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class CloudFoundry < Service
        description "automatic deployment to Cloud Foundry"

        def run
          deploy 'provider' => 'cloudfoundry' do |config|
            target_file = File.expand_path('.cf/config.json', Dir.home)
            config['api']       ||= JSON.parse(File.read(target_file))["Target"] if File.exist? target_file
            config['api']       ||= ask("Cloud Foundry api: ").to_s
            config['username']     ||= ask("Cloud Foundry username: ").to_s
            config['password']     ||= ask("Cloud Foundry password: ") { |q| q.echo = "*" }.to_s
            config['organization'] ||= ask("Cloud Foundry organization: ").to_s
            config['space']        ||= ask("Cloud Foundry space: ").to_s
          end
        end
      end
    end
  end
end