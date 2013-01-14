# encoding: utf-8
require 'travis/cli'
require 'yaml'

module Travis
  module CLI
    class Encrypt < RepoCommand
      attr_accessor :config_key

      on('--add [KEY]', 'adds it to .travis.yml under KEY (default: env.global)') do |c, value|
        c.config_key = value || 'env.global'
      end

      def run(*args)
        data = args.join(" ")

        if data.empty?
          say color("Reading from stdin, press Ctrl+D when done", :info) if $stdin.tty?
          data = $stdin.read
        end

        encrypted = repository.encrypt(data)

        if config_key
          travis_config = YAML.load_file(travis_yaml)
          keys          = config_key.split('.')
          last_key      = keys.pop
          nested_config = keys.inject(travis_config) { |c,k| c[k] ||= {}}
          nested_config[last_key] ||= [] << encrypted
          File.write(travis_yaml, travis_config.to_yaml)
        else
          say encrypted.inspect, template(__FILE__)
        end
      end

      private

        def travis_yaml(dir = Dir.pwd)
          path = File.expand_path('.travis.yml', dir)
          if File.exist? path
            path
          else
            parent = File.expand_path('..', dir)
            travis_yaml(parent) if parent != dir
          end
        end
    end
  end
end

__END__
Please add the following to your <[[ color('.travis.yml', :info) ]]> file:

  secure: %s

Pro Tip<[[ "™" unless Travis::CLI.windows? ]]>: You can add it automatically by running with <[[ color('--add', :info) ]]>.

