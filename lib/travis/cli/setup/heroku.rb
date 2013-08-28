require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Heroku < Service
        description "automatic deployment to Heroku"

        def run
          deploy 'heroku' do |config|
            config['api_key'] = `heroku auth:token 2>/dev/null`.strip
            config['api_key'] = ask("Heroku API token: ") { |q| q.echo = "*" }.to_s if config['api_key'].empty?
            config['app']     = `heroku apps:info 2>/dev/null`.scan(/^=== (.+)$/).flatten.first
            config['app']     = ask("Heroku application name: ") { |q| q.default = repository.name }.to_s if config['app'].nil?
          end
        end
      end
    end
  end
end