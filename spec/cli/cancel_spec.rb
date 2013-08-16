require 'spec_helper'

describe Travis::CLI::Cancel do
  example 'travis cancel' do
    run_cli('cancel', '-t', 'token').should be_success
    $params['id'].should be == "4125095"
    $params['entity'].should be == "builds"
  end

  example 'travis cancel 6180.1' do
    run_cli('cancel', '6180.1', '-t', 'token').should be_success
    $params['id'].should be == "4125096"
    $params['entity'].should be == "jobs"
  end
end
