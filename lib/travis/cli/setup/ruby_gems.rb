require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class RubyGems < Service
        description "automatic release to RubyGems"

        def run
          configure 'deploy', 'provider' => 'rubygems' do |config|
            authorization_file  = File.expand_path('.rubygems/authorization', ENV['HOME'])
            credentials_file    = File.expand_path('.gem/credentials', ENV['HOME'])

            config['api_key'] ||= File.read(authorization_file)                       if File.exist? authorization_file
            config['api_key'] ||= YAML.load_file(credentials_file)[:rubygems_api_key] if File.exist? credentials_file
            config['api_key'] ||= ask("RubyGems API token: ") { |q| q.echo = "*" }.to_s
            config['gem']     ||= ask("Gem name: ") { |q| q.default = repository.name }.to_s

            on("Release only from #{repository.slug}? ", config, 'repo' => repository.slug)
            on("Release only tagged commits? ",          config, 'tags' => true)
            encrypt(config, 'api_key') if agree("Encrypt API key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end