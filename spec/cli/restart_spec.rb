# frozen_string_literal: true

require 'spec_helper'

describe Travis::CLI::Restart do
  example 'travis restart' do
    run_cli('restart', '-t', 'token').should be_success
  end

  example 'travis restart 6180.1' do
    run_cli('restart', '6180.1', '-t', 'token').should be_success
  end
end
