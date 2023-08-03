# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client do
  its(:new) { is_expected.to be_a(Travis::Client::Session) }

  it 'accepts string argument' do
    described_class.new('http://foo/').uri.should be == 'http://foo/'
  end

  it 'accepts options hash with string keys' do
    described_class.new('uri' => 'http://foo/').uri.should be == 'http://foo/'
  end

  it 'accepts options hash with symbol keys' do
    described_class.new(uri: 'http://foo/').uri.should be == 'http://foo/'
  end
end
