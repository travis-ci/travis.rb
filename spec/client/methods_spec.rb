# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Methods do
  subject { OpenStruct.new(session:).extend(described_class) }

  let(:session) { Travis::Client.new }

  before { subject.access_token = 'token' }

  its(:api_endpoint) { is_expected.to be == 'https://api.travis-ci.com/' }
  its(:repos) { is_expected.to be == session.find_many(Travis::Client::Repository) }
  its(:user) { is_expected.to be == session.find_one(Travis::Client::User) }

  it 'fetches a single repo' do
    subject.repo(891).slug.should be == 'rails/rails'
  end
end
