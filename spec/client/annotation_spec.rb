require 'spec_helper'

describe Travis::Client::Annotation do
  let(:session) { Travis::Client.new }
  let(:job) { session.job(4125097) }
  subject { job.annotations.first }
  its(:id) { should be == 1 }
  its(:description) { should be == "The job passed." }
  its(:provider_name) { should be == "Travis CI" }
  its(:url) { should be == "https://travis-ci.org/rails/rails/jobs/4125097" }
  its(:status) { should be == '' }

  it { should be == subject.job.annotations.first }
end
