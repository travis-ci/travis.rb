require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Appfog < Service
        description "automatic deployment to Appfog"

        def run
          deploy 'appfog' do |config|
            config['email'] = ask("Email address: ").to_s
            config['password'] = ask("Password: ") { |q| q.echo = "*" }.to_s
            config['app'] = ask("App name: ") { |q| q.default = repository.name }.to_s
          end
        end
      end
    end
  end
end
