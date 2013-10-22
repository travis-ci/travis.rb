require 'fileutils'

module Travis
  module Tools
    class Completion
      CONFIG_PATH = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', ENV['HOME']) }
      CMP_FILE    = File.expand_path('travis.sh', CONFIG_PATH)
      RCS         = ['.zshrc', '.bashrc'].map { |f| File.expand_path(f, ENV['HOME']) }

      def self.install_completion
        FileUtils.mkdir_p(CONFIG_PATH)
        FileUtils.cp(File.expand_path('../travis.sh', __FILE__), CMP_FILE)

        source = "source " << CMP_FILE

        RCS.each do |file|
          next unless File.exist? file and File.writable? file
          next if File.read(file).include? source
          File.open(file, "a") { |f| f.puts("", "# added by travis gem", "[ -f #{CMP_FILE} ] && #{source}") }
        end
      end

      def self.completion_installed?
        source = "source " << CMP_FILE
        RCS.each do |file|
          next unless File.exist? file and File.writable? file
          return false unless File.read(file).include? source
        end
        true
      end
    end
  end
end
