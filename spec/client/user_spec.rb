require 'spec_helper'

describe Travis::Client::User do
  # attributes :login, :name, :email, :gravatar_id, :locale, :is_syncing, :synced_at, :correct_scopes
  subject { Travis::Client.new(:access_token => 'token').user }
  its(:login) { should be == 'rkh' }
  its(:name) { should be == 'Konstantin Haase' }
  its(:email) { should be == 'konstantin.haase@gmail.com' }
  its(:gravatar_id) { should be == '5c2b452f6eea4a6d84c105ebd971d2a4' }
  its(:locale) { should be == 'en' }
  its(:is_syncing) { should be_false }
  its(:synced_at) { should be_a(Time) }

  it { should_not be_syncing }
  it { should be_correct_scopes }
end
