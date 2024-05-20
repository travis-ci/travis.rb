# frozen_string_literal: true

require 'spec_helper'

describe Travis::CLI::Open do

  before { ENV['TRAVIS_TOKEN'] = 'token' }

  example 'travis open -p' do
    run_cli('open', '-p').should be_success
    stdout.should match(%r{https://travis-ci.com/[\w\W]*/travis\.rb})
  end

  example 'travis open 6180 -p' do
    run_cli('open', '6180', '-p').should be_success
    stdout.should match(%r{https://travis-ci.com/[\w\W]*/travis\.rb/builds/4125095})
  end

  example 'travis open 6180.1 -p' do
    run_cli('open', '6180.1', '-p').should be_success
    stdout.should match(%r{https://travis-ci.com/[\w\W]*/travis\.rb/jobs/4125096})
  end

  example 'travis open -pg' do
    run_cli('open', '-pg').should be_success
    stdout.should match(%r{https://github.com/[\w\W]*/travis\.rb})
  end

  example 'travis open 6180 -pg' do
    run_cli('open', '6180', '-pg').should be_success
    stdout.should be == "https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c\n"
  end

  example 'travis open 6180.1 -pg' do
    run_cli('open', '6180.1', '-pg').should be_success
    stdout.should be == "https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c\n"
  end
end
