require 'spec_helper'

describe Travis::CLI::Endpoint do
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
    stdout.should match(/^".{60,}"\n$/)
  end
end
