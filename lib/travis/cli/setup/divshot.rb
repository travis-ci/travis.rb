require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Divshot < Service
        description "deployment to Divshot.io"

        def run
          deploy 'divshot' do |config|
            config['api_key'] = ask("Divshot Api Key: ") { |q| q.echo = "*" }.to_s
            config['environment'] = ask("Divshot Environment: ").to_s
          end
        end
      end
    end
  end
end