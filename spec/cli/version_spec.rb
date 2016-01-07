require 'spec_helper'

describe Travis::CLI::Version do
  example do
    expect(run_cli('-v')).to be_success
    expect(stdout).to eq("#{Travis::VERSION}\n")
  end

  example do
    expect(run_cli('--version')).to be_success
    expect(stdout).to eq("#{Travis::VERSION}\n")
  end

  example do
    expect(run_cli('version')).to be_success
    expect(stdout).to eq("#{Travis::VERSION}\n")
  end
end
