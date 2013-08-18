require 'travis/cli'
require 'json'

module Travis
  module CLI
    class Setup < RepoCommand
      on('-f', '--force', 'override config section if it already exists')

      def run(service)
        error "unknown service #{service}" unless respond_to? "setup_#{service}"
        public_send "setup_#{service}"
      end

      def setup_heroku
        configure 'deploy', 'provider' => 'heroku' do |config|
          config['api_key'] = `heroku auth:token 2>/dev/null`.strip
          config['api_key'] = ask("Heroku API token: ") { |q| q.echo = "*" }.to_s if config['api_key'].empty?
          config['app']     = `heroku apps:info 2>/dev/null`.scan(/^=== (.+)$/).flatten.first
          config['app']     = ask("Heroku application name: ") { |q| q.default = repository.name }.to_s if config['app'].nil?
          config['on']      = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
          encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
        end
      end

      def setup_engineyard
        configure 'deploy', 'provider' => 'engineyard' do |config|
          eyrc                  = File.expand_path(".eyrc", Dir.home)
          config['api_key']     = YAML.load_file(eyrc)["api_token"] if File.exists?(eyrc)
          config['api_key']     = ask("API token: ") { |q| q.echo = "*" }.to_s unless config['api_key']
          env                   = ask("Environment (optional): ").to_s
          config['environment'] = env unless env.empty?
          migrate               = agree("Run migrations on deploy? ") { |q| q.default = 'yes' }
          config['migrate']     = ask("Migration command: ") { |q| q.default = "rake db:migrate" } if migrate
          config['on']          = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
          encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
        end
      end

      def setup_openshift
        configure 'deploy', 'provider' => 'openshift' do |config|
          config['user']     = ask("OpenShift user: ").to_s
          config['password'] = ask("OpenShift password: ") { |q| q.echo = "*" }.to_s
          config['app']      = ask("OpenShift application name: ") { |q| q.default = repository.name }.to_s
          config['domain']   = ask("OpenShift domain: ").to_s
          config['on']       = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
          encrypt(config, 'password') if agree("Encrypt password? ") { |q| q.default = 'yes' }
        end
      end

      def setup_rubygems
        configure 'deploy', 'provider' => 'rubygems' do |config|
          rubygems_file = File.expand_path('.rubygems/authorization', ENV['HOME'])

          if File.exist? rubygems_file
            config['api_key'] = File.read(rubygems_file)
          end

          config['api_key'] ||= ask("RubyGems API token: ") { |q| q.echo = "*" }.to_s
          config['on']        = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
          encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
        end
      end

      def setup_nodejitsu
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

      def setup_sauce_connect
        travis_config['addons'] ||= {}
        configure 'sauce_connect', {}, travis_config['addons'] do |config|
          config['username']   = ask("Sauce Labs user: ").to_s
          config['access_key'] = ask("Sauce Labs access key: ") { |q| q.echo = "*" }.to_s
          encrypt(config, 'access_key') if agree("Encrypt access key? ") { |q| q.default = 'yes' }
        end
      end

      alias setup_sauce_labs setup_sauce_connect
      alias setup_sauce      setup_sauce_connect

      def setup_cloudcontrol
        configure 'deploy', 'provider' => 'cloudcontrol' do |config|
          config['email']      = ask("cloudControl email: ").to_s
          config['password']   = ask("cloudControl password: ") { |q| q.echo = "*" }.to_s
          app                  = ask("cloudControl application: ") { |q| q.default = repository.name }.to_s
          dep                  = ask("cloudControl deployment: ") { |q| q.default = "default" }.to_s
          config['deployment'] = "#{app}/#{dep}"
          config['on']         = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
          encrypt(config, 'password') if agree("Encrypt password? ") { |q| q.default = 'yes' }
        end
      end

      def setup_cloudfoundry
        configure 'deploy', 'provider' => 'cloudfoundry' do |config|
          config['target']       = ask("Cloud Foundry target: ").to_s
          config['username']     = ask("Cloud Foundry user name: ").to_s
          config['password']     = ask("Cloud Foundry password: ") { |q| q.echo = "*" }.to_s
          config['organization'] = ask("Cloud Foundry organization: ").to_s
          config['space']        = ask("Cloud Foundry space: ").to_s
          config['on']           = { 'repo' => repository.slug } if agree("Deploy only from #{repository.slug}? ") { |q| q.default = 'yes' }
          encrypt(config, 'password') if agree("Encrypt password? ") { |q| q.default = 'yes' }
        end
      end

      private

        def encrypt(config, key)
          encrypted   = repository.encrypt(config.fetch(key))
          config[key] = { 'secure' => encrypted }
        end

        def configure(key, value = {}, config = travis_config)
          error "#{key} section already exists in .travis.yml, run with --force to override" if config.include? key and not force?
          result = yield(config[key] = value)
          save_travis_config
          result
        end
    end
  end
end
