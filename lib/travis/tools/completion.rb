require 'travis/tools/assets'
require 'travis/cli'
require 'fileutils'
require 'erb'

module Travis
  module Tools
    module Completion
      CONFIG_PATH = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', ENV['HOME']) }
      CMP_FILE    = File.expand_path('travis.sh', CONFIG_PATH)
      RCS         = ['.zshrc', '.bashrc'].map { |f| File.expand_path(f, ENV['HOME']) }

      include FileUtils
      extend self

      def install_completion
        mkdir_p(CONFIG_PATH)
        cp(Assets['travis.sh'], CMP_FILE)
        source = "source " << CMP_FILE

        RCS.each do |file|
          next unless File.exist? file and File.writable? file
          next if File.read(file).include? source
          File.open(file, "a") { |f| f.puts("", "# added by travis gem", "[ -f #{CMP_FILE} ] && #{source}") }
        end
      end

      def completion_installed?
        source = "source " << CMP_FILE
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
