require 'spec_helper'

describe Travis::Client::Namespace do
  it { is_expected.to be_a(Travis::Client::Methods) }

  it 'creates a dummy for repos' do
    repo = subject::Repository
    expect(repo.find_one('rails/rails')).to be_a(Travis::Client::Repository)
    expect(repo.find_many).to be_an(Array)
    expect(repo.current).to eq(repo.find_many)
  end

  it 'creates a dummy for user' do
    subject.access_token = 'token'
    user = subject::User
    expect(user.find_one).to be_a(Travis::Client::User)
    expect(user.current).to eq(user.find_one)
  end
end
