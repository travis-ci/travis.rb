require 'spec_helper'

describe Travis::Client do
  describe '#new' do
    subject { super().new }
    it { is_expected.to be_a(Travis::Client::Session) }
  end

  it 'accepts string argument' do
    expect(Travis::Client.new('http://foo/').uri).to eq('http://foo/')
  end

  it 'accepts options hash with string keys' do
    expect(Travis::Client.new('uri' => 'http://foo/').uri).to eq('http://foo/')
  end

  it 'accepts options hash with symbol keys' do
    expect(Travis::Client.new(:uri => 'http://foo/').uri).to eq('http://foo/')
  end
end
