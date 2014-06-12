require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Hackage < Service
        description "automatic deployment of hackage packages"

        def run
          deploy 'hackage' do |config|
            config['username'] ||= ask("Hackage Username: ").to_s
            config['password'] ||= ask("Hackage Password: ") { |q| q.echo = "*" }.to_s
          end
        end
      end
    end
  end
end