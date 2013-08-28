require 'travis/cli/setup'
require 'yaml'

module Travis
  module CLI
    class Setup
      class EngineYard < Service
        description "automatic deployment to Engine Yard"

        def run
          configure 'deploy', 'provider' => 'engineyard' do |config|
            eyrc                  = File.expand_path(".eyrc", Dir.home)
            config['api_key']     = YAML.load_file(eyrc)["api_token"] if File.exists?(eyrc)
            config['api_key']     = ask("API token: ") { |q| q.echo = "*" }.to_s unless config['api_key']
            env                   = ask("Environment (optional): ").to_s
            config['environment'] = env unless env.empty?
            migrate               = agree("Run migrations on deploy? ") { |q| q.default = 'yes' }
            config['migrate']     = ask("Migration command: ") { |q| q.default = "rake db:migrate" } if migrate
            config['on']          = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
            encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end