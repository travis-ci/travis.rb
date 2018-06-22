require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Biicode < Service
        description "automatic publish to biicode"

        def run
          deploy 'biicode', 'release' do |config|
            config['user'] ||= ask("biicode username: ") { |q| q }.to_s
            config['password'] ||= ask("biicode password: ") { |q| q.echo = "*" }.to_s
            on("publish only tagged commits? ", config, 'tags' => true)
          end
        end
      end
    end
  end
end
