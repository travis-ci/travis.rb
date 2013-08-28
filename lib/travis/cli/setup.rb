require 'travis/cli'

module Travis
  module CLI
    class Setup < RepoCommand
      autoload :CloudControl, 'travis/cli/setup/cloud_control'
      autoload :CloudFoundry, 'travis/cli/setup/cloud_foundry'
      autoload :EngineYard,   'travis/cli/setup/engine_yard'
      autoload :Heroku,       'travis/cli/setup/heroku'
      autoload :Nodejitsu,    'travis/cli/setup/nodejitsu'
      autoload :OpenShift,    'travis/cli/setup/open_shift'
      autoload :RubyGems,     'travis/cli/setup/ruby_gems'
      autoload :SauceConnect, 'travis/cli/setup/sauce_connect'
      autoload :Service,      'travis/cli/setup/service'

      description "sets up an addon or deploy target"
      on('-f', '--force', 'override config section if it already exists')

      def self.service(name)
        normal_name = Service.normalized_name(name)
        const_name  = constants(false).detect { |c| Service.normalized_name(c) == normal_name }
        constant    = const_get(const_name) if const_name
        constant if constant and constant < Service and constant.known_as? name
      end

      def self.services
        constants(false).sort.map { |c| const_get(c) }.select { |c| c < Service }
      end

      def help
        services = self.class.services.map { |s| "\t" << color(s.service_name.ljust(20), :command) << color(s.description, :info) }.join("\n")
        super("\nAvailable services:\n\n#{services}\n\n")
      end

      def run(service, file = travis_yaml)
        service(service).run
        save_travis_config(file)
      end

      def service(name)
        factory = self.class.service(name)
        error("unknown service #{name}") unless factory
        factory.new(self)
      end
    end
  end
end
