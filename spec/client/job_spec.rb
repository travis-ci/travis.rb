require 'spec_helper'

describe Travis::Client::Job do
  let(:session) { Travis::Client.new }
  subject { session.job(4125097) }
  its(:number) { should be == '6180.2' }
  its(:state) { should be == 'passed' }
  its(:started_at) { should be_a(Time) }
  its(:finished_at) { should be_a(Time) }
  its(:inspect) { should be == "#<Travis::Client::Job: rails/rails#6180.2>" }
  its(:color) { should be == 'green' }
  its(:commit) { should be_a(Travis::Client::Commit) }
  its(:repository) { should be == session.repo('rails/rails') }
  its(:duration) { should be == 905 }

  it { should be == subject.build.jobs[1] }

  it { should_not be_pending      }
  it { should     be_started      }
  it { should     be_finished     }
  it { should     be_passed       }
  it { should_not be_errored      }
  it { should_not be_failed       }
  it { should_not be_canceled     }
  it { should     be_created      }
  it { should_not be_red          }
  it { should     be_green        }
  it { should_not be_yellow       }
  it { should_not be_unsuccessful }
end
