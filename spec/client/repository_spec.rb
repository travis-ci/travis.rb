require 'spec_helper'

describe Travis::Client::Repository do
  let(:session) { Travis::Client.new }
  subject { session.repo('rails/rails') }

  describe '#slug' do
    subject { super().slug }
    it { is_expected.to eq('rails/rails') }
  end

  describe '#description' do
    subject { super().description }
    it { is_expected.not_to be_empty }
  end

  describe '#last_build_id' do
    subject { super().last_build_id }
    it { is_expected.to eq(4125095) }
  end

  describe '#last_build_number' do
    subject { super().last_build_number }
    it { is_expected.to eq('6180') }
  end

  describe '#last_build_state' do
    subject { super().last_build_state }
    it { is_expected.to eq('failed') }
  end

  describe '#last_build_duration' do
    subject { super().last_build_duration }
    it { is_expected.to eq(5019) }
  end

  describe '#last_build_started_at' do
    subject { super().last_build_started_at }
    it { is_expected.to be_a(Time) }
  end

  describe '#last_build_finished_at' do
    subject { super().last_build_finished_at }
    it { is_expected.to be_nil }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq("#<Travis::Client::Repository: rails/rails>") }
  end

  describe '#key' do
    subject { super().key }
    it { is_expected.to be_a(Travis::Client::Repository::Key) }
  end

  describe '#last_build' do
    subject { super().last_build }
    it { is_expected.to be_a(Travis::Client::Build) }
  end

  describe '#color' do
    subject { super().color }
    it { is_expected.to eq('red') }
  end

  describe '#github_language' do
    subject { super().github_language }
    it { is_expected.to eq('Ruby') }
  end

  describe '#owner_name' do
    subject { super().owner_name }
    it { is_expected.to eq('rails') }
  end

  describe '#owner' do
    subject { super().owner }
    it { is_expected.to eq(session.account("rails")) }
  end

  it { is_expected.not_to be_pending  }
  it { is_expected.to     be_started  }
  it { is_expected.to     be_finished }
  it { is_expected.not_to be_passed   }
  it { is_expected.not_to be_errored  }
  it { is_expected.to     be_failed   }
  it { is_expected.not_to be_canceled }
  it { is_expected.to     be_created  }
  it { is_expected.to     be_red      }
  it { is_expected.not_to be_green    }
  it { is_expected.not_to be_yellow   }
  it { is_expected.to be_unsuccessful }

  it 'should expose the pubkey fingerprint' do
    expect(subject.public_key.fingerprint).to eq('foobar')
  end
end
