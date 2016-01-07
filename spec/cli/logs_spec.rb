require 'spec_helper'

describe Travis::CLI::Logs do
  example 'logs 6180.1' do
    expect(run_cli('logs', '6180.1', '-E')).to be_success
    expect(stdout).to eq("$ export GEM=railties\n")
  end
end
