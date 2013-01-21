require 'spec_helper'

describe Travis::CLI::Logs do
  example 'logs 6180.1' do
    run_cli('logs', '6180.1', '-E').should be_success
    stdout.should be == "$ export GEM=railties\n"
  end
end
