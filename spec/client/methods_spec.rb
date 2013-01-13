require 'spec_helper'

describe Travis::Client::Methods do
  let(:session) { Travis::Client.new }
  subject { OpenStruct.new(:session => session).extend(Travis::Client::Methods) }
  before { subject.access_token = 'token' }

  its(:api_endpoint) { should be == 'https://api.travis-ci.org/' }
  its(:repos) { should be == session.find_many(Travis::Client::Repository) }
  its(:user) { should be == session.find_one(Travis::Client::User) }

  it 'fetches a single repo' do
    subject.repo(891).slug.should be == 'rails/rails'
  end
end
