require 'spec_helper'

describe Travis::CLI::Token do
  example "travis token (access token set)" do
    run_cli('token', '-t', 'super-secret').should be_success
    stdout.should == "super-secret\n"
    stderr.should be_empty
  end

  example "travis token -i (access token set)" do
    run_cli('token', '-it', 'super-secret').should be_success
    stdout.should == "Your access token is super-secret\n"
    stderr.should be_empty
  end

  example 'travis token (no access token set)' do
    run_cli('token').should_not be_success

    stdout.should be_empty
    stderr.should == "not logged in, please run #{File.basename($0)} login\n"
  end
end
