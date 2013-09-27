require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class NPM < Service
        description "automatic release to NPM"

        def run
          deploy 'npm', 'release' do |config|
            config['email'] ||= ask("NPM email address: ") { |q| q }.to_s
            config['api_key'] ||= ask("NPM api key: ") { |q| q.echo = "*" }.to_s

            on("release only tagged commits? ", config, 'tags' => true)
          end
        end
      end
    end
  end
end
