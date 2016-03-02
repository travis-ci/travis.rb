require 'spec_helper'

describe Travis::CLI::Crons do
  example 'show crons' do
    run_cli('crons').should be_success
  end
end
