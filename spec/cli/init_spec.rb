require 'spec_helper'

describe Travis::CLI::Init do
  all_languages = ['ruby']

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

  all_languages.each do | language |
    example "travis init #{language} (empty directory)" do
      run_cli('init', language).should be_success
      stdout.should be == ".travis.yml file created!\n"
    end
  end

  all_languages.each do | language |
    example "travis init #{language} (.travis.yml already exists, using --force)" do
      File.open(".travis.yml", "w") {}
      run_cli('init', language, '--force').should be_success
      stdout.should be == ".travis.yml file created!\n"
    end
  end

  all_languages.each do | language |
    example "travis init #{language} (.travis.yml already exists, not using --force)" do
      File.open(".travis.yml", "w") {}
      run_cli('init', 'ruby').should_not be_success
      stderr.should be == ".travis.yml already exists, use --force to override\n"
    end
  end

end