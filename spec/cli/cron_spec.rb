require 'spec_helper'

describe Travis::CLI::Cron do
  example 'list cron' do

    run_cli('cron', 'list', '-t', 'token').should be_success
    stdout.should include("Branch: master")
    stdout.should include("Interval: weekly")
  end

  example 'create cron' do
    run_cli('cron', 'create', 'debug', 'daily', '-t', 'token', '-i').should be_success
    stdout.should be == "Cron with id 378 created.\n"
  end

  example 'create cron' do
    run_cli('cron', 'delete', '378', '-t', 'token', '-i').should be_success
    stdout.should be == "Cron with id 378 deleted.\n"
  end
end
