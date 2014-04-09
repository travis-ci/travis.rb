require 'spec_helper'

describe Travis::CLI::History do
  example 'travis history' do
    run_cli('history').should be_success
    stdout.should be == "#6180 failed:    master Associaton -> Association\n"
  end

  example 'travis history -d' do
    run_cli('history', '-d').should be_success
    stdout.should be =~ /2013-01-13 \d+:55:17 #6180 failed:    master Associaton -> Association/
  end

  example 'travis history -a 6180' do
    run_cli('history', '-a', '6180').should be_success
    stdout.should be == ''
  end

  example 'travis history -b master' do
    run_cli('history', '-b', 'master').should be_success
    stdout.should be == "#6180 failed:    master Associaton -> Association\n"
  end

  example 'travis history -b not-master' do
    run_cli('history', '-b', 'not-master').should be_success
    stdout.should be_empty
  end

  example 'travis history -p 5' do
    run_cli('history', '-p', '5').should be_success
    stdout.should be_empty
  end

  example 'travis history -c' do
    run_cli('history', '-c').should be_success
    stdout.should be == "#6180 failed:    master Steve Klabnik             Associaton -> Association\n"
  end
end
