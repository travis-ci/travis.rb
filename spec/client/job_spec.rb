# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Job do
  subject { session.job(4_125_097) }

  let(:session) { Travis::Client.new }

  its(:number) { is_expected.to be == '6180.2' }
  its(:state) { is_expected.to be == 'passed' }
  its(:started_at) { is_expected.to be_a(Time) }
  its(:finished_at) { is_expected.to be_a(Time) }
  its(:inspect) { is_expected.to be == '#<Travis::Client::Job: rails/rails#6180.2>' }
  its(:color) { is_expected.to be == 'green' }
  its(:commit) { is_expected.to be_a(Travis::Client::Commit) }
  its(:repository) { is_expected.to be == session.repo('rails/rails') }
  its(:duration) { is_expected.to be == 905 }

  it { is_expected.to be == subject.build.jobs[1] }

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
