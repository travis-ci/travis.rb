require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Deis < Service
        description "automatic deployment to a deis app"

        def run
          deploy 'deis' do |config|
            config['controller'] ||= ask("Deis Controller: ").to_s
            config['app']        ||= ask("Deis App: ").to_s
            config['username']   ||= ask("Deis Username: ").to_s
            config['password']   ||= ask("Deis Password: ") { |q| q.echo = "*" }.to_s
          end
        end
      end
    end
  end
end