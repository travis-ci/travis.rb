require 'travis/cli/setup'
require 'json'

module Travis
  module CLI
    class Setup
      class Nodejitsu < Service
        description "automatic deployment to Nodejitsu"

        def run
          configure 'deploy', 'provider' => 'nodejitsu' do |config|
            jitsu_file = File.expand_path('.jitsuconf', ENV['HOME'])

            if File.exist? jitsu_file
              jitsu_conf        = JSON.parse(File.read(jitsu_file))
              config['user']    = jitsu_conf['username']
              config['api_key'] = jitsu_conf['apiToken']
            end

            config['user']    ||= ask("Nodejitsu user: ").to_s
            config['api_key'] ||= ask("Nodejitsu API token: ") { |q| q.echo = "*" }.to_s
            config['on']        = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
            encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end