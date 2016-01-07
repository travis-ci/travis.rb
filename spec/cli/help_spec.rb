require 'spec_helper'

describe Travis::CLI::Help do
  example "travis help" do
    expect(run_cli('help')).to be_success
    expect(stdout).to include("Usage: travis COMMAND")
  end

  example "travis --help" do
    expect(run_cli('--help')).to be_success
    expect(stdout).to include("Usage: travis COMMAND")
  end

  example "travis -h" do
    expect(run_cli('-h')).to be_success
    expect(stdout).to include("Usage: travis COMMAND")
  end

  example "travis -?" do
    expect(run_cli('-?')).to be_success
    expect(stdout).to include("Usage: travis COMMAND")
  end

  example "travis help endpoint" do
    expect(run_cli('help', 'endpoint')).to be_success
    expect(stdout).to include("Usage: travis endpoint [OPTIONS]")
  end

  example "travis endpoint --help" do
    expect(run_cli('endpoint', '--help')).to be_success
    expect(stdout).to include("Usage: travis endpoint [OPTIONS]")
  end
end
