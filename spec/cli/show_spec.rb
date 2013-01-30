require 'spec_helper'

describe Travis::CLI::Show do
  example 'show 6180.1' do
    run_cli('show', '6180.1', '-E').should be_success
    stdout.should include("Config:        ")
    stdout.should include("env: GEM=railties")
  end
end
