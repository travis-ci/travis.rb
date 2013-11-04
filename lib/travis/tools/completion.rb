require 'travis/tools/assets'
require 'travis/cli'
require 'fileutils'
require 'erb'

module Travis
  module Tools
    module Completion
      RCS = ['.zshrc', '.bashrc'].map { |f| File.expand_path(f, ENV['HOME']) }
      include FileUtils
      extend self

      def config_path
        ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', ENV['HOME']) }
      end

      def cmp_file
        File.expand_path('travis.sh', config_path)
      end

      def install_completion
        update_completion
        source = "source " << cmp_file

        RCS.each do |file|
          next unless File.exist? file and File.writable? file
          next if File.read(file).include? source
          File.open(file, "a") { |f| f.puts("", "# added by travis gem", "[ -f #{cmp_file} ] && #{source}") }
        end
      end

      def update_completion
        mkdir_p(config_path)
        cp(Assets['travis.sh'], cmp_file)
      end

      def completion_installed?
        source = "source " << config_path
        RCS.each do |file|
          next unless File.exist? file and File.writable? file
          return false unless File.read(file).include? source
        end
        true
      end

      def compile
        commands = Travis::CLI.commands.sort_by { |c| c.command_name }
        template = Assets.read('travis.sh.erb')
        source   = ERB.new(template).result(binding).gsub(/^ +\n/, '')
        File.write(Assets['travis.sh'], source)
      end
    end
  end
end
