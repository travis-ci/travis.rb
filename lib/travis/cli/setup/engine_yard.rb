require 'travis/cli/setup'
require 'yaml'

module Travis
  module CLI
    class Setup
      class EngineYard < Service
        description "automatic deployment to Engine Yard"

        def run
          deploy 'engineyard' do |config|
            eyrc                  = File.expand_path(".eyrc", Dir.home)
            config['api_key']     = YAML.load_file(eyrc)["api_token"] if File.exists?(eyrc)
            config['api_key']     = ask("API token: ") { |q| q.echo = "*" }.to_s unless config['api_key']
            env                   = ask("Environment (optional): ").to_s
            config['environment'] = env unless env.empty?
            migrate               = agree("Run migrations on deploy? ") { |q| q.default = 'yes' }
            config['migrate']     = ask("Migration command: ") { |q| q.default = "rake db:migrate" } if migrate
          end
        end
      end
    end
  end
end
