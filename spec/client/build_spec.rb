require 'spec_helper'

describe Travis::Client::Build do
  let(:session) { Travis::Client.new }
  subject { session.build(4125095) }

  describe '#number' do
    subject { super().number }
    it { is_expected.to eq('6180') }
  end

  describe '#state' do
    subject { super().state }
    it { is_expected.to eq('failed') }
  end

  describe '#duration' do
    subject { super().duration }
    it { is_expected.to eq(5019) }
  end

  describe '#started_at' do
    subject { super().started_at }
    it { is_expected.to be_a(Time) }
  end

  describe '#finished_at' do
    subject { super().finished_at }
    it { is_expected.to be_nil }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq("#<Travis::Client::Build: rails/rails#6180>") }
  end

  describe '#color' do
    subject { super().color }
    it { is_expected.to eq('red') }
  end

  describe '#commit' do
    subject { super().commit }
    it { is_expected.to be_a(Travis::Client::Commit) }
  end

  describe '#jobs' do
    subject { super().jobs }
    it { is_expected.to be_an(Array) }
  end

  describe '#repository' do
    subject { super().repository }
    it { is_expected.to eq(session.repo('rails/rails')) }
  end

  it { is_expected.to eq(subject.repository.last_build) }

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
end
