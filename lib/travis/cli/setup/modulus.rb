require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Modulus < Service
        description "deployment to Modulus"

        def run
          deploy 'modulus' do |config|
            config['api_key'] = ask("Modulus Api Key: ") { |q| q.echo = "*" }.to_s
            config['project_name'] = ask("Modulus Project Name: ").to_s
          end
        end
      end
    end
  end
end
