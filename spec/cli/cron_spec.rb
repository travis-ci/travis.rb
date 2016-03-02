require 'spec_helper'

describe Travis::CLI::Cron do
  example 'list cron' do
    run_cli('cron', 'list').should be_success
  end

  example 'create cron' do
    run_cli('cron', 'create', 'master', 'daily').should be_success
  end
end
