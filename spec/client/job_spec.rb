require 'spec_helper'

describe Travis::Client::Job do
  let(:session) { Travis::Client.new }
  subject { session.job(4125097) }

  describe '#number' do
    subject { super().number }
    it { is_expected.to eq('6180.2') }
  end

  describe '#state' do
    subject { super().state }
    it { is_expected.to eq('passed') }
  end

  describe '#started_at' do
    subject { super().started_at }
    it { is_expected.to be_a(Time) }
  end

  describe '#finished_at' do
    subject { super().finished_at }
    it { is_expected.to be_a(Time) }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq("#<Travis::Client::Job: rails/rails#6180.2>") }
  end

  describe '#color' do
    subject { super().color }
    it { is_expected.to eq('green') }
  end

  describe '#commit' do
    subject { super().commit }
    it { is_expected.to be_a(Travis::Client::Commit) }
  end

  describe '#repository' do
    subject { super().repository }
    it { is_expected.to eq(session.repo('rails/rails')) }
  end

  describe '#duration' do
    subject { super().duration }
    it { is_expected.to eq(905) }
  end

  it { is_expected.to eq(subject.build.jobs[1]) }

  it { is_expected.not_to be_pending      }
  it { is_expected.to     be_started      }
  it { is_expected.to     be_finished     }
  it { is_expected.to     be_passed       }
  it { is_expected.not_to be_errored      }
  it { is_expected.not_to be_failed       }
  it { is_expected.not_to be_canceled     }
  it { is_expected.to     be_created      }
  it { is_expected.not_to be_red          }
  it { is_expected.to     be_green        }
  it { is_expected.not_to be_yellow       }
  it { is_expected.not_to be_unsuccessful }
end
