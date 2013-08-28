require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class SauceConnect < Service
        description "Sauce Connet addon for Sauce Labs integration"
        service_name "sauce_connect"

        def run
          travis_config['addons'] ||= {}
          configure 'sauce_connect', {}, travis_config['addons'] do |config|
            config['username']   = ask("Sauce Labs user: ").to_s
            config['access_key'] = ask("Sauce Labs access key: ") { |q| q.echo = "*" }.to_s
            encrypt(config, 'access_key') if agree("Encrypt access key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end