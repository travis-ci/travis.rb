# frozen_string_literal: true

require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Service
        def self.normalized_name(string)
          string.to_s.downcase.gsub(/[^a-z\d]/, '')
        end

        def self.description(description = nil)
          @description ||= ''
          @description = description if description
          @description
        end

        def self.service_name(service_name = nil)
          @service_name ||= normalized_name(name[/[^:]+$/])
          @service_name = service_name if service_name
          @service_name
        end

        def self.known_as?(name)
          normalized_name(service_name) == normalized_name(name)
        end

        attr_accessor :command

        def initialize(command)
          @command = command
        end

        def method_missing(*args, &block)
          @command.send(*args, &block)
        end

        private

        def on(question, config, condition)
          return unless agree(question) { |q| q.default = 'yes' }

          config['on'] ||= {}
          config['on'].merge! condition
        end

        def encrypt(config, key)
          encrypted   = repository.encrypt(config.fetch(key))
          config[key] = { 'secure' => encrypted }
        end

        def configure(key, value = {}, config = travis_config)
          if config.include?(key) && !force?
            error "#{key} section already exists in .travis.yml, run with --force to override"
          end
          yield(config[key] = value)
        end

        def branch
          @branch ||= `git rev-parse --symbolic-full-name --abbrev-ref HEAD`.chomp
        end

        def deploy(provider, verb = 'deploy')
          configure('deploy', 'provider' => provider) do |config|
            yield config

            on("#{verb.capitalize} only from #{repository.slug}? ", config, 'repo' => repository.slug)
            if (branch != 'master') && (branch != 'HEAD')
              on("#{verb.capitalize} from #{branch} branch? ", config,
                 'branch' => branch)
            end

            config['skip_cleanup'] = 'true' unless config.key?('skip_cleanup') || (config.fetch('edge',
                                                                                                'false') != 'false')

            encrypt(config, 'password') if config['password'] && agree('Encrypt Password? ') do |q|
                                             q.default = 'yes'
                                           end
            encrypt(config, 'api_key')  if config['api_key']  && agree('Encrypt API key? ') { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end
