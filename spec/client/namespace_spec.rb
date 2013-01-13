require 'spec_helper'

describe Travis::Client::Namespace do
  it { should be_a(Travis::Client::Methods) }

  it 'creates a dummy for repos' do
    repo = subject::Repository
    repo.find_one('rails/rails').should be_a(Travis::Client::Repository)
    repo.find_many.should be_an(Array)
    repo.current.should be == repo.find_many
  end

  it 'creates a dummy for user' do
    subject.access_token = 'token'
    user = subject::User
    user.find_one.should be_a(Travis::Client::User)
    user.current.should be == user.find_one
  end
end
