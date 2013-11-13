require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class CloudFiles < Service
        description "automatic pushing to Rackspace Cloud Files"

        def run
          deploy 'cloudfiles' do |config|
            config['username'] = ask("Rackspace Username: ").to_s
            config['api_key'] = ask("Rackspace Api Key: ") { |q| q.echo = "*" }.to_s
            config['region'] = ask("Cloud Files Region: ").to_s
            config['container'] = ask("Container: ").to_s
          end
        end
      end
    end
  end
end
