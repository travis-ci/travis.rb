# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Build do
  subject { session.build(4_125_095) }

  let(:session) { Travis::Client.new }

  its(:number) { is_expected.to be == '6180' }
  its(:state) { is_expected.to be == 'failed' }
  its(:duration) { is_expected.to be == 5019 }
  its(:started_at) { is_expected.to be_a(Time) }
  its(:finished_at) { is_expected.to be_nil }
  its(:inspect) { is_expected.to be == '#<Travis::Client::Build: rails/rails#6180>' }
  its(:color) { is_expected.to be == 'red' }
  its(:commit) { is_expected.to be_a(Travis::Client::Commit) }
  its(:jobs) { is_expected.to be_an(Array) }
  its(:repository) { is_expected.to be == session.repo('rails/rails') }

  it { is_expected.to be == subject.repository.last_build }

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
