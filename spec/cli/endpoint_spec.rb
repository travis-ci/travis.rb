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

  example "TRAVIS_ENDPOINT=http://localhost:3000/ travis endpoint" do
    ENV['TRAVIS_ENDPOINT'] = "http://localhost:3000/"
    run_cli('endpoint').should be_success
    stdout.should be == "http://localhost:3000/\n"
  end

  example "travis endpoint --github" do
    run_cli('endpoint', '--github').should be_success
    stdout.should be == "https://api.github.com\n"
  end

  example "travis endpoint -i" do
    run_cli('endpoint', '-i').should be_success
    stdout.should be == "API endpoint: https://api.travis-ci.org/\n"
  end
end
