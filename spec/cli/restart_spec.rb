require 'spec_helper'

describe Travis::CLI::Restart do
  example 'travis restart' do
    run_cli('restart', '-t', 'token').should be_success
    $params['id'].should be == "4125095"
    $params['entity'].should be == "builds"
  end

  example 'travis restart 6180.1' do
    run_cli('restart', '6180.1', '-t', 'token').should be_success
    $params['entity'].should be == "jobs"
    $params['id'].should be == "4125096"
  end
end
