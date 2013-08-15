require 'spec_helper'

describe Travis::CLI::Setup do
  example 'setup cloudcontrol' do
    run_cli('setup', 'cloudcontrol') { |i|
      i.puts('email')
      i.puts('password')
      i.puts('application')
      i.puts('deployment')
      i.puts('yes')
      i.puts('yes')}.should be_success
    stdout.should be == "cloudControl email: cloudControl password: ********\ncloudControl application: cloudControl deployment: Deploy only from rails/rails? |yes| Encrypt password key? |yes| "
    file = File.expand_path('.travis.yml', Dir.pwd.gsub!(/\/spec/, ''))
    config = YAML.load_file(file)
    
    config['deploy']['provider'].should eql('cloudcontrol')
    config['deploy']['email'].should eql('email')
    config['deploy']['deployment'].should eql('application/deployment')

    config.delete('deploy')
    yaml = config.to_yaml
    yaml.gsub! /\A---\s*\n/, ''
    File.write(file, yaml)
  end
end
