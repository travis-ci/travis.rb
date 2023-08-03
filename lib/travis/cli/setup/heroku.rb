# frozen_string_literal: true

require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Heroku < Service
        description 'automatic deployment to Heroku'

        def run
          deploy 'heroku' do |config|
            config['api_key'] = `heroku auth:token 2>/dev/null`.strip
            config['api_key'] = ask('Heroku API token: ') { |q| q.echo = '*' }.to_s if config['api_key'].empty?
            config['app']     = `heroku apps:info 2>/dev/null`.scan(/^=== (.+)$/).flatten.first
            if config['app'].nil?
              config['app'] = ask('Heroku application name: ') do |q|
                q.default = repository.name
              end.to_s
            end
          end
        end
      end
    end
  end
end
