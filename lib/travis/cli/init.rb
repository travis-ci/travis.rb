require 'travis/cli'

module Travis
  module CLI
    class Init < Enable
      description "generates a .travis.yml and enables the project"

      on('-f', '--force', 'override .travis.yml if it already exists')
      on('-k', '--skip-enable', 'do not enable project, only add .travis.yml')
      on('-p', '--print-conf', 'print generated config instead of writing to file')

      options = %w[
        script before_script after_script after_success install before_install
        compiler otp_release go jdk node_js perl php python rvm scala
        env gemfile
      ]

      options.each do |option|
        on "--#{option.gsub('_', '-')} VALUE", "sets #{option} option in .travis.yml (can be used more than once)" do |c, value|
          c.custom_config[option] &&= Array(c.custom_config[option]) << value
          c.custom_config[option] ||= value
        end
      end

      attr_writer :travis_config

      def run(language = nil, file = '.travis.yml')
        error ".travis.yml already exists, use --force to override" if File.exist?(file) and not force? and not print_conf?
        language ||= ask('Main programming language used: ') { |q| q.default = detect_language }
        self.travis_config = template(language).merge(custom_config)

        if print_conf?
          puts travis_config.to_yaml
        else
          save_travis_config(file)
          say("#{file} file created!")
        end

        super() unless skip_enable?
      end

      def custom_config
        @custom_config ||= {}
      end

      private

        def template(language)
          file = File.expand_path("../init/#{language}.yml", __FILE__)
          error "unknown language #{language}" unless File.exist? file
          YAML.load_file(file)
        end

        def detect_language
          'ruby'
        end
    end
  end
end