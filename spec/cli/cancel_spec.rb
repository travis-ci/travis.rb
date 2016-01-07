require 'spec_helper'

describe Travis::CLI::Cancel do
  example 'travis cancel' do
    expect(run_cli('cancel', '-t', 'token')).to be_success
    expect($params['id']).to eq("4125095")
    expect($params['entity']).to eq("builds")
  end

  example 'travis cancel 6180.1' do
    expect(run_cli('cancel', '6180.1', '-t', 'token')).to be_success
    expect($params['id']).to eq("4125096")
    expect($params['entity']).to eq("jobs")
  end
end
