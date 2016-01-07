require 'spec_helper'

describe Travis::Client::Methods do
  let(:session) { Travis::Client.new }
  subject { OpenStruct.new(:session => session).extend(Travis::Client::Methods) }
  before { subject.access_token = 'token' }

  describe '#api_endpoint' do
    subject { super().api_endpoint }
    it { is_expected.to eq('https://api.travis-ci.org/') }
  end

  describe '#repos' do
    subject { super().repos }
    it { is_expected.to eq(session.find_many(Travis::Client::Repository)) }
  end

  describe '#user' do
    subject { super().user }
    it { is_expected.to eq(session.find_one(Travis::Client::User)) }
  end

  it 'fetches a single repo' do
    expect(subject.repo(891).slug).to eq('rails/rails')
  end
end
