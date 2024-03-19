# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::User do
  # attributes :login, :name, :email, :gravatar_id, :locale, :is_syncing, :synced_at, :correct_scopes
  subject { Travis::Client.new(access_token: 'token').user }

  its(:login) { is_expected.to be == 'rkh' }
  its(:name) { is_expected.to be == 'Konstantin Haase' }
  its(:email) { is_expected.to be == 'konstantin.haase@gmail.com' }
  its(:gravatar_id) { is_expected.to be == '5c2b452f6eea4a6d84c105ebd971d2a4' }
  its(:locale) { is_expected.to be == 'en' }
  its(:is_syncing) { is_expected.to be false }
  its(:synced_at) { is_expected.to be_a(Time) }

  it { is_expected.not_to be_syncing }
  it { is_expected.to be_correct_scopes }
end
