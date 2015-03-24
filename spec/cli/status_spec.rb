require 'spec_helper'

describe Travis::CLI::Status do
  example "travis status" do
    run_cli('status').should be_success
    stdout.should be == "failed\n"
  end

  example "travis status -x" do
    run_cli('status', '-x').should_not be_success
    stdout.should be == "failed\n"
  end

  example "travis status -q" do
    run_cli('status', '-q').should be_success
    stdout.should be_empty
  end

  example "travis status -pqx" do
    run_cli('endpoint', '-pqx').should_not be_success
    stdout.should be_empty
  end

  example "travis status -i" do
    run_cli('status', '-i', '--skip-completion-check', '-r', 'travis-ci/travis.rb').should be_success
    stdout.should be == "build #6180 failed\n"
  end
end
