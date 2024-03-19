# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Repository do
  subject(:repository) { session.repo('rails/rails') }

  let(:session) { Travis::Client.new }

  its(:slug) { is_expected.to be == 'rails/rails' }
  its(:description) { is_expected.not_to be_empty }
  its(:last_build_id) { is_expected.to be == 4_125_095 }
  its(:last_build_number) { is_expected.to be == '6180' }
  its(:last_build_state) { is_expected.to be == 'failed' }
  its(:last_build_duration) { is_expected.to be == 5019 }
  its(:last_build_started_at) { is_expected.to be_a(Time) }
  its(:last_build_finished_at) { is_expected.to be_nil }
  its(:inspect) { is_expected.to be == '#<Travis::Client::Repository: rails/rails>' }
  its(:key) { is_expected.to be_a(Travis::Client::Repository::Key) }
  its(:last_build) { is_expected.to be_a(Travis::Client::Build) }
  its(:color) { is_expected.to be == 'red' }
  its(:github_language) { is_expected.to be == 'Ruby' }
  its(:owner_name) { is_expected.to be == 'rails' }
  its(:owner) { is_expected.to be == session.account('rails') }

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

  it 'exposes the pubkey fingerprint' do
    repository.public_key.fingerprint.should be == 'foobar'
  end
end
