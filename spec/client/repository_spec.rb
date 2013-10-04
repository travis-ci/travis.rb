require 'spec_helper'

describe Travis::Client::Repository do
  let(:session) { Travis::Client.new }
  subject { session.repo('rails/rails') }

  its(:slug) { should be == 'rails/rails' }
  its(:description) { should_not be_empty }
  its(:last_build_id) { should be == 4125095 }
  its(:last_build_number) { should be == '6180' }
  its(:last_build_state) { should be == 'failed' }
  its(:last_build_duration) { should be == 5019 }
  its(:last_build_started_at) { should be_a(Time) }
  its(:last_build_finished_at) { should be_nil }
  its(:inspect) { should be == "#<Travis::Client::Repository: rails/rails>" }
  its(:key) { should be_a(Travis::Client::Repository::Key) }
  its(:last_build) { should be_a(Travis::Client::Build) }
  its(:color) { should be == 'red' }
  its(:github_language) { should be == 'Ruby' }
  its(:owner_name) { should be == 'rails' }
  its(:owner) { should be == session.account("rails") }

  it { should_not be_pending  }
  it { should     be_started  }
  it { should     be_finished }
  it { should_not be_passed   }
  it { should_not be_errored  }
  it { should     be_failed   }
  it { should_not be_canceled }
  it { should     be_created  }
  it { should     be_red      }
  it { should_not be_green    }
  it { should_not be_yellow   }
  it { should be_unsuccessful }
end
