require 'spec_helper'
require 'uri'

describe Travis::CLI::RepoCommand do
  describe '#parse_remote' do
    it 'handles git@github.com URIs' do
      path = subject.send(:parse_remote, 'git@github.com:travis-ci/travis.rb.git')
      path.should be == '/travis-ci/travis.rb.git'
    end

    it 'handles GitHub Enterprise URIS' do
      path = subject.send(:parse_remote, 'git@example.com:travis-ci/travis.rb.git')
      path.should be == '/travis-ci/travis.rb.git'
    end

    it 'handles HTTPS URIs' do
      path = subject.send(:parse_remote, 'https://github.com/travis-ci/travis.rb.git')
      path.should be == '/travis-ci/travis.rb.git'
    end

    it 'raises URI::InvalidURIError for invalid URIs' do
      expect { subject.send(:parse_remote, "foo@example.com:baz/bar.git") }.to raise_error(URI::InvalidURIError)
    end
  end
end
