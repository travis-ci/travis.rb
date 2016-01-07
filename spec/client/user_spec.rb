require 'spec_helper'

describe Travis::Client::User do
  # attributes :login, :name, :email, :gravatar_id, :locale, :is_syncing, :synced_at, :correct_scopes
  subject { Travis::Client.new(:access_token => 'token').user }

  describe '#login' do
    subject { super().login }
    it { is_expected.to eq('rkh') }
  end

  describe '#name' do
    subject { super().name }
    it { is_expected.to eq('Konstantin Haase') }
  end

  describe '#email' do
    subject { super().email }
    it { is_expected.to eq('konstantin.haase@gmail.com') }
  end

  describe '#gravatar_id' do
    subject { super().gravatar_id }
    it { is_expected.to eq('5c2b452f6eea4a6d84c105ebd971d2a4') }
  end

  describe '#locale' do
    subject { super().locale }
    it { is_expected.to eq('en') }
  end

  describe '#is_syncing' do
    subject { super().is_syncing }
    it { is_expected.to be_falsey }
  end

  describe '#synced_at' do
    subject { super().synced_at }
    it { is_expected.to be_a(Time) }
  end

  it { is_expected.not_to be_syncing }
  it { is_expected.to be_correct_scopes }
end
