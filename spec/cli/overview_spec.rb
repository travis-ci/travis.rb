require 'spec_helper'

describe Travis::CLI::Overview do
  example 'overview branches' do
    run_cli('overview', 'branches', '-t', 'token').should be_success
    stdout.should be == "master: 67%\ndevel: 51%\n"
    stderr.should include("passing builds in last 30 days")
  end

  example 'overview duration' do
    run_cli('overview', 'duration', '-t', 'token').should be_success
    stdout.should be ==
      "build 5 passed in 29 seconds\n" +
      "build 3 passed in 30 seconds\n" +
      "build 1 errored in 24 seconds\n"
      
    stderr.should include("duration of last 20 builds")
  end

  example 'overview history' do
    run_cli('overview', 'history', '-t', 'token').should be_success
    stdout.should be ==
      "2016-02-25:\n" +
      "   passed: 1\n" +
      "2016-03-01:\n" +
      "   canceled: 1\n"

    stderr.should include("build statuses in last 10 days")
  end

  example 'overview eventType' do
    run_cli('overview', 'eventType', '-t', 'token').should be_success
    stdout.should be ==
      "push:\n" +
      "   failed: 3\n" +
      "   errored: 1\n" +
      "pull_request:\n" +
      "   passed: 11\n" +
      "   errored: 1\n" +
      "cron:\n" +
      "   failed: 1\n" +
      "   canceled: 2\n"

    stderr.should include("statuses by event type")
  end

  example 'overview streak' do
    run_cli('overview', 'streak', '-t', 'token').should be_success
    stdout.should be == "Your streak is 0 days and 0 builds.\n"
  end
end
