require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Artifacts < Service
        description 'automatic artifact shipping to S3'
        service_name 'artifacts'

        def run
          travis_config['addons'] ||= {}
          configure 'artifacts', {}, travis_config['addons'] do |config|
            config['key'] = ask("Access key ID: ").to_s
            config['secret'] = ask("Secret access key: ") { |q| q.echo = "*" }.to_s
            config['bucket'] = ask("Bucket: ").to_s
            encrypt(config, 'key') if agree("Encrypt access key ID? ") { |q| q.default = 'yes' }
            encrypt(config, 'secret') if agree("Encrypt secret access key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end
