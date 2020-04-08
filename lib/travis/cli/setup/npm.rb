require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class NPM < Service
        description "automatic release to npm"

        def run
          deploy 'npm', 'release' do |config|
            config['email'] ||= ask("npm email address: ") { |q| q }.to_s
            config['api_key'] ||= ask("npm api key: ") { |q| q.echo = "*" }.to_s

            on("release only tagged commits? ", config, 'tags' => true)
          end
        end
      end
    end
  end
end
