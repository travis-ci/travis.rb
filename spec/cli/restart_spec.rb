require 'spec_helper'

describe Travis::CLI::Restart do
  example 'travis restart' do
    run_cli('restart', '-t', 'token').should be_success
    $params['build_id'].should be == "4125095"
    $params['job_id'].should be_nil
  end

  example 'travis restart 6180.1' do
    run_cli('restart', '6180.1', '-t', 'token').should be_success
    $params['build_id'].should be_nil
    $params['job_id'].should be == "4125096"
  end
end