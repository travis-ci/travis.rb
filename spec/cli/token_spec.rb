require 'spec_helper'

describe Travis::CLI::Token do
  example "travis token (access token set)" do
    expect(run_cli('token', '-t', 'super-secret')).to be_success
    expect(stdout).to eq("super-secret\n")
    expect(stderr).to be_empty
  end

  example "travis token -i (access token set)" do
    expect(run_cli('token', '-it', 'super-secret')).to be_success
    expect(stdout).to eq("Your access token is super-secret\n")
    expect(stderr).to be_empty
  end

  example 'travis token (no access token set)' do
    expect(run_cli('token')).not_to be_success

    expect(stdout).to be_empty
    expect(stderr).to eq("not logged in, please run #{File.basename($0)} login\n")
  end
end
