require 'spec_helper'

describe Travis::CLI::Init do
  before(:each) do
    FileUtils.mkdir_p "spec/tmp"
    Dir.chdir "spec/tmp"
    FileUtils.rm('.travis.yml') if File.exist?('.travis.yml')
  end

  after(:each) do
    Dir.chdir ".."
    FileUtils.rm('spec/tmp/.travis.yml') if File.exist?('spec/tmp/.travis.yml')
  end

  example "travis init fakelanguage" do
    run_cli('init', 'fakelanguage').should_not be_success
    stderr.should be == "unknown language fakelanguage\n"
  end

  shared_examples_for 'travis init' do |language|
    example "travis init #{language} (empty directory)" do
      File.exist?('.travis.yml').should be_false
      run_cli('init', language).should be_success
      stdout.should be == ".travis.yml file created!\n"
      File.exist?('.travis.yml').should be_true
      File.read('.travis.yml').should include("language: #{language}")
    end

    example "travis init #{language} (.travis.yml already exists, using --force)" do
      File.open(".travis.yml", "w") { |f| f << "old file" }
      run_cli('init', language, '--force').should be_success
      stdout.should be == ".travis.yml file created!\n"
      File.read(".travis.yml").should_not be == "old file"
    end

    example "travis init #{language} (.travis.yml already exists, not using --force)" do
      File.open(".travis.yml", "w") { |f| f << "old file" }
      run_cli('init', 'ruby').should_not be_success
      stderr.should be == ".travis.yml already exists, use --force to override\n"
      File.read('.travis.yml').should be == "old file"
    end
  end

  describe 'travis init ruby' do
    it_should_behave_like 'travis init', 'ruby'
  end
end