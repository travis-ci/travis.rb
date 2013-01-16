require 'spec_helper'

describe Travis::Client::Build do
  let(:session) { Travis::Client.new }
  subject { session.build(4125095) }
  its(:number) { should be == '6180' }
  its(:state) { should be == 'failed' }
  its(:duration) { should be == 5019 }
  its(:started_at) { should be_a(Time) }
  its(:finished_at) { should be_nil }
  its(:inspect) { should be == "#<Travis::Client::Build: rails/rails#6180>" }
  its(:color) { should be == 'red' }
  its(:commit) { should be_a(Travis::Client::Commit) }
  its(:jobs) { should be_an(Array) }
  its(:repository) { should be == session.repo('rails/rails') }

  it { should be == subject.repository.last_build }

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
