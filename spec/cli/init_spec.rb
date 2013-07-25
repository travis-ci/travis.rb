require 'spec_helper'

describe Travis::CLI::Init do

  all_languages = Travis::CLI::Init::LANGUAGES

  before(:each) do
    FileUtils.mkdir_p "spec/tmp"
    Dir.chdir "spec/tmp"
    FileUtils.rm('.travis.yml') if File.exist?('.travis.yml')
  end

  after(:each) do
    Dir.chdir ".."
    FileUtils.rm('spec/tmp/.travis.yml') if File.exist?('spec/tmp/.travis.yml')
  end

  example "travis init" do
    run_cli('init').should_not be_success
    stderr.should be == "no language given.\n"
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
    example "travis init #{language} (.travis.yml already exists, answer yes)" do
      File.open(".travis.yml", "w") {}
      run_cli('init', language){ |i| i.puts('yes') }.should be_success
      stdout.should be == ".travis.yml already exists, do you want to overwrite?\nFile overwritten!\n.travis.yml file created!\n"
    end
  end

  all_languages.each do | language |
    example "travis init #{language} (.travis.yml already exists, answer no)" do
      File.open(".travis.yml", "w") {}
      run_cli('init', 'ruby'){ |i| i.puts('no') }.should_not be_success
      stdout.should be == ".travis.yml already exists, do you want to overwrite?\n"
      stderr.should be == "You chose not to overwrite, task cancelled.\n"
    end
  end

end