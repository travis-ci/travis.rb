config_path = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', ENV['HOME']) }

require 'fileutils'
FileUtils.mkdir_p(config_path)
FileUtils.cp(File.expand_path('../travis.sh', __FILE__), config_path)

rcs = ['.zshrc', '.bashrc'].map { |f| File.expand_path(f, ENV['HOME']) }
source = "source " << File.expand_path('travis.sh', config_path)

rcs.each do |file|
  next unless File.exist? file and File.writable? file
  next if File.read(file).include? source
  File.open(file, "a") { |f| f.puts("", "# added by travis gem", source) }
end

# fake Makefile
File.open('Makefile', 'w') { |f| f.puts 'all:', 'install:' }
