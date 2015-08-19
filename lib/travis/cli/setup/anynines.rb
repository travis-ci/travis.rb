require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Anynines < Service
        description "automatic deployment to anynines"

        def run
          deploy 'anynines' do |config|
            config['username']     ||= ask("anynines username: ").to_s
            config['password']     ||= ask("anynines password: ") { |q| q.echo = "*" }.to_s
            config['organization'] ||= ask("anynines organization: ").to_s
            config['space']        ||= ask("anynines space: ").to_s
          end
        end

      end
    end
  end
end
