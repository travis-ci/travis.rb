require 'spec_helper'

describe Travis::CLI::Encrypt do
  example "travis encrypt foo" do
    run_cli('encrypt', 'foo').should be_success
    stdout.should match(/^".{60,}"\n$/)
  end

  example "travis encrypt foo -r rails/rails" do
    run_cli('encrypt', 'foo', '-r', 'rails/rails').should be_success
    stdout.should match(/^".{60,}"\n$/)
  end

  example "travis encrypt foo -i" do
    run_cli('encrypt', 'foo', '-i', '--skip-completion-check', '-r', 'travis-ci/travis.rb').should be_success
    stdout.should start_with("Please add the following to your .travis.yml file:\n\n  secure: ")
  end

  example "cat foo | travis encrypt" do
    run_cli('encrypt') { |i| i.puts('foo') }
    stdout.should match(/\A".{60,}"\n\Z/)
  end

  example "cat foo\\nbar | travis encrypt -s" do
    run_cli('encrypt', '-s') { |i| i.puts("foo\nbar") }
    stdout.should match(/\A(".{60,}"\n){2}\Z/)
  end

  example "cat foo\\nbar | travis encrypt" do
    run_cli('encrypt') { |i| i.puts("foo\nbar") }
    stdout.should match(/\A".{60,}"\n\Z/)
  end

  example "travis encrypt rails/rails foo" do
    run_cli('encrypt', 'rails/rails', 'foo').should be_success
    stderr.should match(/WARNING/)
  end

  example "travis encrypt foo=foo/bar" do
    run_cli("encrypt", "foo=foo/bar").should be_success
    stderr.should_not match(/WARNING/)
  end

  example "travis encrypt FOO bar -a" do
    described_class.any_instance.stub(:save_travis_config)
    run_cli("encrypt", "FOO", "bar", "-a") { |i| i.puts "foo" }.should be_success
    stderr.should match(/Environment variables in env\.global should be formatted as FOO=bar/)
  end

  example "travis encrypt FOO bar -a foo" do
    described_class.any_instance.stub(:save_travis_config)
    run_cli("encrypt", "FOO", "bar", "-a", "foo") { |i| i.puts "foo" }.should be_success
    stdout.should match(/Overwrite the config file/)
  end

  example "travis encrypt FOO bar -a --no-interactive" do
    described_class.any_instance.stub(:save_travis_config)
    run_cli("encrypt", "FOO", "bar", "-a", "--no-interactive").should be_success
    stderr.should match(/Environment variables in env\.global should be formatted as FOO=bar/)
  end

  example "travis encrypt FOO=bar -a foo --no-interactive" do
    described_class.any_instance.stub(:save_travis_config)
    run_cli("encrypt", "FOO=bar", "-a", "foo", "--no-interactive").should be_success
    stdout.should be_empty
  end
end
