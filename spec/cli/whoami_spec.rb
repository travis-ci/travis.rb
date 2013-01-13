require 'spec_helper'

describe Travis::CLI::Whoami do
  example "travis whoami" do
    run_cli('whoami').should_not be_success
    stdout.should be_empty
    stderr.should be == "not logged in, please run #$0 login\n"
  end

  example "travis whoami --pro" do
    run_cli('whoami', '--pro').should_not be_success
    stdout.should be_empty
    stderr.should be == "not logged in, please run #$0 login --pro\n"
  end

  example "travis whoami -t token" do
    run_cli('whoami', '-t', 'token').should be_success
    stdout.should be == "rkh\n"
    stderr.should be_empty
  end

  example "travis whoami -t token -i" do
    run_cli('whoami', '-t', 'token', '-i').should be_success
    stdout.should be == "You are \e[1m\e[4mrkh\e[0m (Konstantin Haase)\n"
    stderr.should be_empty
  end
end
