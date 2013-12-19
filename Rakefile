# encoding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
windows = RUBY_PLATFORM =~ /mswin|mingw/

desc "run specs"
task(:spec) { ruby "-S rspec spec#{" -c" unless windows}" }

desc "generate gemspec, update readme"
task :update => :completion do
  require 'travis/version'
  content = File.read('travis.gemspec')

  # fetch data
  fields = {
    :authors => `git shortlog -sn`.b.scan(/[^\d\s].*/).map { |a| a == 'petems' ? 'Peter Souter' : a },
    :email   => `git shortlog -sne`.b.scan(/[^<]+@[^>]+/),
    :files   => `git ls-files`.b.split("\n").reject { |f| f =~ /^(\.|Gemfile)/ }
  }

  # :(
  fields[:email].delete("konstantin.haase@gmail.com")
  fields[:authors]

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
  readme.gsub! /^(\s+\$ travis version\n\s+).*$/, "\\1#{Travis::VERSION}"
  readme.gsub! /(gem install travis -v )\S+/, "\\1#{Travis::VERSION}"
  readme.gsub! /^\*\*#{Regexp.escape(Travis::VERSION)}\*\* \(not yet released?\)\n/i, "**#{Travis::VERSION}** (#{Time.now.strftime("%B %-d, %Y")})\n"

  Travis::CLI.commands.each do |c|
    readme.sub! /^(        \* \[\`#{c.command_name}\`\]\(##{c.command_name}\)).*$/, "\\1 - #{c.description}"
  end

  File.write('README.md', readme)
end

task :completion do
  require 'travis/tools/completion'
  Travis::Tools::Completion.compile
end

task 'travis.gemspec' => :update
task 'README.md'      => :update

task :gemspec => :update
task :default => :spec
task :default => :gemspec unless windows or RUBY_VERSION < '2.0'
task :test    => :spec