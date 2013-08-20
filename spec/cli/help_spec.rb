require 'spec_helper'

describe Travis::CLI::Help do
  example "travis help" do
    run_cli('help').should be_success
    stdout.should include("Usage: travis COMMAND")
  end

  example "travis --help" do
    run_cli('--help').should be_success
    stdout.should include("Usage: travis COMMAND")
  end

  example "travis -h" do
    run_cli('-h').should be_success
    stdout.should include("Usage: travis COMMAND")
  end

  example "travis -?" do
    run_cli('-?').should be_success
    stdout.should include("Usage: travis COMMAND")
  end

  example "travis help endpoint" do
    run_cli('help', 'endpoint').should be_success
    stdout.should include("Usage: travis endpoint [options]")
  end

  example "travis endpoint --help" do
    run_cli('endpoint', '--help').should be_success
    stdout.should include("Usage: travis endpoint [options]")
  end
end
