# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'digest'

describe Travis::CLI::EncryptFile do
  CMD_TARGET = 'README.md'

  before do

    ENV['TRAVIS_TOKEN'] = 'token'
    Digest.stub(:hexencode).and_return 'randomhex' # to avoid relying on Dir.pwd value for hex
  end

  after do
    FileUtils.rm_f "#{CMD_TARGET}.enc"
  end

  example "travis encrypt-file #{CMD_TARGET}" do
    run_cli('encrypt-file', CMD_TARGET).should be_success
    File.exist?("#{CMD_TARGET}.enc").should be true
  end

  example "travis encrypt-file #{CMD_TARGET} -a" do
    run_cli('encrypt-file', CMD_TARGET, '-a') { |i| i.puts 'n' }.should be_success
    stdout.should match(/Overwrite the config file/)
    File.exist?("#{CMD_TARGET}.enc").should be true
  end
end
