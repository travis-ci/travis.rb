require 'spec_helper'

describe Travis::CLI::Logs do
  example 'show 6180.1' do
    run_cli('show', '6180.1').should be_success
    stdout.should include("Config:        rvm: 1.9.3, env: GEM=railties")
  end
end
