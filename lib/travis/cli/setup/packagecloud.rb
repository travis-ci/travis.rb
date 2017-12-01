require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Packagecloud < Service
        description "automatic deployment to packagecloud"

        def run
          deploy 'packagecloud' do |config|
            config['username']   ||= ask("Username: ").to_s
            config['repository'] ||= ask("Repository: ").to_s
            config['dist']       ||= ask("Package dist/version \(supported dists: https://packagecloud.io/docs#os_distro_version\): ").to_s
            config['token']      ||= ask("API token: ") { |q| q.echo = "*" }.to_s

            encrypt(config, 'token') if agree("Encrypt API token? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end
