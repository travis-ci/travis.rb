# frozen_string_literal: true

require 'spec_helper'

describe Travis::CLI::Cancel do
  example 'travis cancel' do
    run_cli('cancel', '-t', 'token').should be_success
  end

  example 'travis cancel 6180.1' do
    run_cli('cancel', '6180.1', '-t', 'token').should be_success
  end
end
