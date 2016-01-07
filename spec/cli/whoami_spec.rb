require 'spec_helper'

describe Travis::CLI::Whoami do
  example "travis whoami" do
    expect(run_cli('whoami')).not_to be_success
    expect(stdout).to be_empty
    expect(stderr).to eq("not logged in, please run #{File.basename $0} login\n")
  end

  example "travis whoami --pro" do
    expect(run_cli('whoami', '--pro')).not_to be_success
    expect(stdout).to be_empty
    expect(stderr).to eq("not logged in, please run #{File.basename $0} login --pro\n")
  end

  example "travis whoami -t token" do
    expect(run_cli('whoami', '-t', 'token')).to be_success
    expect(stdout).to eq("rkh\n")
    expect(stderr).to be_empty
  end

  example "TRAVIS_TOKEN=token travis whoami" do
    ENV['TRAVIS_TOKEN'] = 'token'
    expect(run_cli('whoami')).to be_success
    expect(stdout).to eq("rkh\n")
    expect(stderr).to be_empty
  end

  example "travis whoami -t token -i" do
    expect(run_cli('whoami', '-t', 'token', '-i')).to be_success
    expect(stdout).to eq("You are rkh (Konstantin Haase)\n")
    expect(stderr).to be_empty
  end
end
