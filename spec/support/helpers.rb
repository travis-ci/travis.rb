require 'spec_helper'
require 'stringio'
require 'ostruct'

module Helpers
  attr_reader :last_run

  def capture
    _stdout, $stdout = $stdout, StringIO.new
    _stderr, $stderr = $stderr, StringIO.new
    _stdin,  $stdin  = $stdin,  StringIO.new
    yield
    capture_result(true)
  rescue SystemExit => e
    capture_result(e.success?)
  ensure
    $stdout = _stdout if _stdout
    $stderr = _stderr if _stderr
    $stdin  = _stdin  if _stdin
  end

  def run_cli(*args)
    args << ENV['TRAVIS_OPTS'] if ENV['TRAVIS_OPTS']
    args << '--skip-version-check' << '--skip-completion-check'
    capture do
      yield $stdin if block_given?
      $stdin.rewind
      Travis::CLI.run(*args)
    end
  end

  def stderr
    last_run.err if last_run
  end

  def stdout
    last_run.out if last_run
  end

  private

    def capture_result(success)
      @last_run = OpenStruct.new(:out => $stdout.string, :err => $stderr.string, :success? => success)
    end
end
