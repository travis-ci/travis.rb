require 'spec_helper'

describe Travis::CLI::Status do
  example "travis status" do
    expect(run_cli('status')).to be_success
    expect(stdout).to eq("failed\n")
  end

  example "travis status -x" do
    expect(run_cli('status', '-x')).not_to be_success
    expect(stdout).to eq("failed\n")
  end

  example "travis status -q" do
    expect(run_cli('status', '-q')).to be_success
    expect(stdout).to be_empty
  end

  example "travis status -pqx" do
    expect(run_cli('endpoint', '-pqx')).not_to be_success
    expect(stdout).to be_empty
  end

  example "travis status -i" do
    expect(run_cli('status', '-i', '--skip-completion-check', '-r', 'travis-ci/travis.rb')).to be_success
    expect(stdout).to eq("build #6180 failed\n")
  end
end
