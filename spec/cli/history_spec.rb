require 'spec_helper'

describe Travis::CLI::History do
  example 'travis history' do
    expect(run_cli('history')).to be_success
    expect(stdout).to eq("#6180 failed:    master Associaton -> Association\n")
  end

  example 'travis history -d' do
    expect(run_cli('history', '-d')).to be_success
    expect(stdout).to match(/2013-01-13 \d+:55:17 #6180 failed:    master Associaton -> Association/)
  end

  example 'travis history -a 6180' do
    expect(run_cli('history', '-a', '6180')).to be_success
    expect(stdout).to eq('')
  end

  example 'travis history -b master' do
    expect(run_cli('history', '-b', 'master')).to be_success
    expect(stdout).to eq("#6180 failed:    master Associaton -> Association\n")
  end

  example 'travis history -b not-master' do
    expect(run_cli('history', '-b', 'not-master')).to be_success
    expect(stdout).to be_empty
  end

  example 'travis history -p 5' do
    expect(run_cli('history', '-p', '5')).to be_success
    expect(stdout).to be_empty
  end

  example 'travis history -c' do
    expect(run_cli('history', '-c')).to be_success
    expect(stdout).to eq("#6180 failed:    master Steve Klabnik             Associaton -> Association\n")
  end
end
