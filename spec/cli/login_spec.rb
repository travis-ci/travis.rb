require 'spec_helper'

describe Travis::CLI::Login do
  example "travis login" do
    run_cli('login') { |i| i.puts('rkh', 'password') }.should be_success
    run_cli('whoami').out.should be == "rkh\n"
  end

  example "travis login (with bad credentials)" do
    run_cli('login') { |i| i.puts('rkh', 'wrong password') }.should_not be_success
    run_cli('whoami').should_not be_success
  end
end
