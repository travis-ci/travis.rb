# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Namespace do
  subject(:namespace) { described_class.new }

  it { is_expected.to be_a(Travis::Client::Methods) }

  it 'creates a dummy for repos' do
    repo = namespace::Repository
    repo.find_one('rails/rails').should be_a(Travis::Client::Repository)
    repo.find_many.should be_an(Array)
    repo.current.should be == repo.find_many
  end

  it 'creates a dummy for user' do
    namespace.access_token = 'token'
    user = namespace::User
    user.find_one.should be_a(Travis::Client::User)
    user.current.should be == user.find_one
  end
end
