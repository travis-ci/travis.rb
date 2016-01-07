require 'spec_helper'

describe Travis::CLI::Restart do
  example 'travis restart' do
    expect(run_cli('restart', '-t', 'token')).to be_success
    expect($params['build_id']).to eq("4125095")
    expect($params['job_id']).to be_nil
  end

  example 'travis restart 6180.1' do
    expect(run_cli('restart', '6180.1', '-t', 'token')).to be_success
    expect($params['build_id']).to be_nil
    expect($params['job_id']).to eq("4125096")
  end
end