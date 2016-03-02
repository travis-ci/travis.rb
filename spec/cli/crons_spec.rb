require 'spec_helper'

describe Travis::CLI::Crons do
  example 'show crons' do
    run_cli('crons', '-t', 'token', '--debug').should be_success
    stdout.should include("Cron 378 builds weekly on master.\n")
  end
end
