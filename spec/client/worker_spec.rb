require 'spec_helper'

describe Travis::Client::Worker do
  let(:session) { Travis::Client.new }
  subject { session.workers.first }

  its(:id)         { should be == 'foo'                         }
  its(:name)       { should be == 'ruby-1'                      }
  its(:host)       { should be == 'ruby-1.worker.travis-ci.org' }
  its(:state)      { should be == 'ready'                       }
  its(:color)      { should be == 'green'                       }
  its(:job)        { should be_a(Travis::Client::Job)           }
  its(:repository) { should be_a(Travis::Client::Repository)    }

  it { should be_ready }

  describe 'without payload' do
    subject { session.worker('foo') }
    its(:payload)    { should be == {}}
    its(:job)        { should be_nil  }
    its(:repository) { should be_nil  }
  end
end
