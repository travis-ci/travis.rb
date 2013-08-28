require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Heroku < Service
        description "automatic deployment to Heroku"

        def run
          configure 'deploy', 'provider' => 'heroku' do |config|
            config['api_key'] = `heroku auth:token 2>/dev/null`.strip
            config['api_key'] = ask("Heroku API token: ") { |q| q.echo = "*" }.to_s if config['api_key'].empty?
            config['app']     = `heroku apps:info 2>/dev/null`.scan(/^=== (.+)$/).flatten.first
            config['app']     = ask("Heroku application name: ") { |q| q.default = repository.name }.to_s if config['app'].nil?
            config['on']      = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
            encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end