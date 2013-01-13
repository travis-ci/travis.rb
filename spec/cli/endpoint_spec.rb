require 'spec_helper'

describe Travis::CLI::Endpoint do
  example "travis endpoint" do
    run_cli('endpoint').should be_success
    stdout.should be == "https://api.travis-ci.org/\n"
  end

  example "travis endpoint --pro" do
    run_cli('endpoint', '--pro').should be_success
    stdout.should be == "https://api.travis-ci.com/\n"
  end

  example "travis endpoint -e http://localhost:3000/" do
    run_cli('endpoint', '-e', 'http://localhost:3000/').should be_success
    stdout.should be == "http://localhost:3000/\n"
  end

  example "travis endpoint -i" do
    run_cli('endpoint', '-i').should be_success
    stdout.should be == "API endpoint: \e[1m\e[4mhttps://api.travis-ci.org/\e[0m\n"
  end
end
