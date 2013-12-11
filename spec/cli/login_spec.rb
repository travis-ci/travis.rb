require 'spec_helper'

describe Travis::CLI::Login do
  example "travis login", :unless => Travis::Tools::System.windows? do
    run_cli('login', '-E', '--skip-token-check') { |i| i.puts('rkh', 'password') }.should be_success
    run_cli('whoami').out.should be == "rkh\n"
  end

  example "travis login (with bad credentials)", :unless => Travis::Tools::System.windows? do
    run_cli('login') { |i| i.puts('rkh', 'wrong password') }.should_not be_success
    run_cli('whoami').should_not be_success
  end
end
