require 'spec_helper'

describe Travis::CLI::Version do
  example do
    run_cli('-v').should be_success
    stdout.should be == "#{Travis::VERSION}\n"
  end

  example do
    run_cli('--version').should be_success
    stdout.should be == "#{Travis::VERSION}\n"
  end

  example do
    run_cli('version').should be_success
    stdout.should be == "#{Travis::VERSION}\n"
  end
end
