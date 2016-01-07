require 'spec_helper'

describe Travis::CLI::Encrypt do
  example "travis encrypt foo" do
    expect(run_cli('encrypt', 'foo')).to be_success
    expect(stdout).to match(/^".{60,}"\n$/)
  end

  example "travis encrypt foo -r rails/rails" do
    expect(run_cli('encrypt', 'foo', '-r', 'rails/rails')).to be_success
    expect(stdout).to match(/^".{60,}"\n$/)
  end

  example "travis encrypt foo -i" do
    expect(run_cli('encrypt', 'foo', '-i', '--skip-completion-check', '-r', 'travis-ci/travis.rb')).to be_success
    expect(stdout).to start_with("Please add the following to your .travis.yml file:\n\n  secure: ")
  end

  example "cat foo | travis encrypt" do
    run_cli('encrypt') { |i| i.puts('foo') }
    expect(stdout).to match(/\A".{60,}"\n\Z/)
  end

  example "cat foo\\nbar | travis encrypt -s" do
    run_cli('encrypt', '-s') { |i| i.puts("foo\nbar") }
    expect(stdout).to match(/\A(".{60,}"\n){2}\Z/)
  end

  example "cat foo\\nbar | travis encrypt" do
    run_cli('encrypt') { |i| i.puts("foo\nbar") }
    expect(stdout).to match(/\A".{60,}"\n\Z/)
  end

  example "travis encrypt rails/rails foo" do
    expect(run_cli('encrypt', 'rails/rails', 'foo')).to be_success
    expect(stderr).to match(/WARNING/)
  end

  example "travis encrypt foo=foo/bar" do
    expect(run_cli("encrypt", "foo=foo/bar")).to be_success
    expect(stderr).not_to match(/WARNING/)
  end
end
