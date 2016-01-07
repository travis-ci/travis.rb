require 'spec_helper'

describe Travis::CLI::Login do
  example "travis login", :unless => Travis::Tools::System.windows? do
    expect(run_cli('login', '-E', '--skip-token-check') { |i| i.puts('rkh', 'password') }).to be_success
    expect(run_cli('whoami').out).to eq("rkh\n")
  end

  example "travis login (with bad credentials)", :unless => Travis::Tools::System.windows? do
    expect(run_cli('login') { |i| i.puts('rkh', 'wrong password') }).not_to be_success
    expect(run_cli('whoami')).not_to be_success
  end
end
