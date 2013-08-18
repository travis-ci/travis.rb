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
    run_cli('encrypt', 'foo', '-i').should be_success
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
end
