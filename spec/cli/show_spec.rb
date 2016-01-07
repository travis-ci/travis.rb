require 'spec_helper'

describe Travis::CLI::Show do
  example 'show 6180.1' do
    expect(run_cli('show', '6180.1', '-E')).to be_success
    expect(stdout).to include("Config:        ")
    expect(stdout).to include("env: GEM=railties")
  end
end
