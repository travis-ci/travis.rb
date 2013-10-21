config_path = ENV.fetch('TRAVIS_CONFIG_PATH') { File.expand_path('.travis', ENV['HOME']) }
cmp_file    = File.expand_path('travis.sh', config_path)

require 'fileutils'
FileUtils.mkdir_p(config_path)
FileUtils.cp(File.expand_path('../travis.sh', __FILE__), cmp_file)

rcs    = ['.zshrc', '.bashrc'].map { |f| File.expand_path(f, ENV['HOME']) }
source = "source " << cmp_file

rcs.each do |file|
  next unless File.exist? file and File.writable? file
  next if File.read(file).include? source
  File.open(file, "a") { |f| f.puts("", "# added by travis gem", "[ -f #{cmp_file} ] && #{source}") }
end

# fake Makefile
File.open('Makefile', 'w') { |f| f.puts 'all:', 'install:' }
