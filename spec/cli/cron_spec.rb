require 'spec_helper'

describe Travis::CLI::Cron do
  example 'list cron' do
    run_cli('cron', 'list', '-t', 'token').should be_success
    stdout.should include("Branch: master")
    stdout.should include("Interval: weekly")
  end

  example 'create cron with correct interval' do
    run_cli('cron', 'create', 'debug', 'daily', '-t', 'token').should be_success
    stdout.should be == "Cron with id 378 created.\n"
  end

  example 'create cron with wrong interval' do
    run_cli('cron', 'create', 'debug', 'wrongInterval', '-t', 'token').should_not be_success
    stderr.should include("Interval must be daily, weekly or monthly. got wrongInterval")
  end

  example 'create cron with correct disable_by_build' do
    run_cli('cron', 'create', 'debug', 'daily', 'true', '-t', 'token').should be_success
    stdout.should be == "Cron with id 378 created.\n"
  end

  example 'create cron with wrong disable_by_build' do
    run_cli('cron', 'create', 'debug', 'daily', 'anything', '-t', 'token').should_not be_success
    stderr.should include("Disable_by_build must be true or false. got anything")
  end

  example 'delete cron' do
    run_cli('cron', 'delete', '378', '-t', 'token').should be_success
    stdout.should be == "Cron with id 378 deleted.\n"
  end
end
