require 'spec_helper'

describe Travis::CLI::Endpoint do
  example "travis endpoint" do
    expect(run_cli('endpoint')).to be_success
    expect(stdout).to eq("https://api.travis-ci.org/\n")
  end

  example "travis endpoint --pro" do
    expect(run_cli('endpoint', '--pro')).to be_success
    expect(stdout).to eq("https://api.travis-ci.com/\n")
  end

  example "travis endpoint -e http://localhost:3000/" do
    expect(run_cli('endpoint', '-e', 'http://localhost:3000/')).to be_success
    expect(stdout).to eq("http://localhost:3000/\n")
  end

  example "TRAVIS_ENDPOINT=http://localhost:3000/ travis endpoint" do
    ENV['TRAVIS_ENDPOINT'] = "http://localhost:3000/"
    expect(run_cli('endpoint')).to be_success
    expect(stdout).to eq("http://localhost:3000/\n")
  end

  example "travis endpoint --github" do
    expect(run_cli('endpoint', '--github')).to be_success
    expect(stdout).to eq("https://api.github.com\n")
  end

  example "travis endpoint -i" do
    expect(run_cli('endpoint', '-i')).to be_success
    expect(stdout).to eq("API endpoint: https://api.travis-ci.org/\n")
  end
end
