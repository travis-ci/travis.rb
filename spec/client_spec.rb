require 'spec_helper'

describe Travis::Client do
  its(:new) { should be_a(Travis::Client::Session) }

  it 'accepts string argument' do
    Travis::Client.new('http://foo/').uri.should be == 'http://foo/'
  end

  it 'accepts options hash with string keys' do
    Travis::Client.new('uri' => 'http://foo/').uri.should be == 'http://foo/'
  end

  it 'accepts options hash with symbol keys' do
    Travis::Client.new(:uri => 'http://foo/').uri.should be == 'http://foo/'
  end
end
