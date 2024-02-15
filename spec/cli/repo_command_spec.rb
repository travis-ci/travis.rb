# frozen_string_literal: true

require 'spec_helper'
require 'uri'

describe Travis::CLI::RepoCommand do
  describe '#parse_remote' do
    subject(:repo_command) { described_class.new }

    it 'handles git@github.com URIs' do
      path = repo_command.send(:parse_remote, 'git@github.com:travis-ci/travis.rb.git')
      path.should be == '/travis-ci/travis.rb.git'
    end

    it 'handles GitHub Enterprise URIS' do
      path = repo_command.send(:parse_remote, 'git@example.com:travis-ci/travis.rb.git')
      path.should be == '/travis-ci/travis.rb.git'
    end

    it 'handles HTTPS URIs' do
      path = repo_command.send(:parse_remote, 'https://github.com/travis-ci/travis.rb.git')
      path.should be == '/travis-ci/travis.rb.git'
    end

    it 'raises URI::InvalidURIError for invalid URIs' do
      expect { repo_command.send(:parse_remote, 'foo@example.com:baz/bar.git') }.to raise_error(URI::InvalidURIError)
    end
  end
end
