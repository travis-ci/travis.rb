require 'spec_helper'

describe Travis::CLI::Init do

  before(:each) do
    Dir.chdir "tmp"
    FileUtils.rm('.travis.yml') if File.exist?('.travis.yml')
  end

  after(:each) do
    Dir.chdir ".."
    FileUtils.rm('tmp/.travis.yml') if File.exist?('tmp/.travis.yml')
  end

  example "travis init (empty directory)" do
    run_cli('init').should be_success
    stdout.should be == ".travis.yml file created!\n"
  end

  example "travis init (.travis.yml already exists, answer yes)" do
    File.open(".travis.yml", "w") {}
    run_cli('init'){ |i| i.puts('yes') }.should be_success
    stdout.should be == ".travis.yml already exists, do you want to overwrite?\nFile overwritten!\n.travis.yml file created!\n"
  end

  example "travis init (.travis.yml already exists, answer no)" do
    File.open(".travis.yml", "w") {}
    run_cli('init'){ |i| i.puts('no') }.should_not be_success
    stdout.should be == ".travis.yml already exists, do you want to overwrite?\n"
    stderr.should match("You chose not to overwrite, task cancelled.")
  end
end