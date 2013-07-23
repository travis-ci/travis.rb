# encoding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
windows = RUBY_PLATFORM =~ /mswin|mingw/

desc "run specs"
task(:spec) { ruby "-S rspec spec#{" -c" unless windows}" }

desc "generate gemspec, update readme"
task 'update' do
  require 'travis/version'
  content = File.read('travis.gemspec')

  # fetch data
  fields = {
    :authors => `git shortlog -sn`.b.scan(/[^\d\s].*/),
    :email   => `git shortlog -sne`.b.scan(/[^<]+@[^>]+/),
    :files   => `git ls-files`.b.split("\n").reject { |f| f =~ /^(\.|Gemfile)/ }
  }

  # :(
  fields[:email].delete("konstantin.haase@gmail.com")

  # insert data
  fields.each do |field, values|
    updated = "  s.#{field} = ["
    updated << values.map { |v| "\n    %p" % v }.join(',')
    updated << "\n  ]"
    content.sub!(/  s\.#{field} = \[\n(    .*\n)*  \]/, updated)
  end

  # set version
  content.sub! /(s\.version.*=\s+).*/, "\\1\"#{Travis::VERSION}\""

  # escape unicode
  content.gsub!(/./) { |c| c.bytesize > 1 ? "\\u{#{c.codepoints.first.to_s(16)}}" : c }

  File.open('travis.gemspec', 'w') { |f| f << content }

  readme = File.read('README.md').b
  readme.gsub! /^(\s+\$ travis verision\n\s+).*$/, "\\1#{Travis::VERSION}"
  readme.gsub! /(gem install travis -v )\S+/, "\\1#{Travis::VERSION}"
  File.write('README.md', readme)
end

task 'travis.gemspec' => :update
task 'README.md'      => :update

task :gemspec => :update
task :default => :spec
task :default => :gemspec unless windows or ENV['CI']
task :test    => :spec