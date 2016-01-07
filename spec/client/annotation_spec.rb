require 'spec_helper'

describe Travis::Client::Annotation do
  let(:session) { Travis::Client.new }
  let(:job) { session.job(4125097) }
  subject { job.annotations.first }

  describe '#id' do
    subject { super().id }
    it { is_expected.to eq(1) }
  end

  describe '#description' do
    subject { super().description }
    it { is_expected.to eq("The job passed.") }
  end

  describe '#provider_name' do
    subject { super().provider_name }
    it { is_expected.to eq("Travis CI") }
  end

  describe '#url' do
    subject { super().url }
    it { is_expected.to eq("https://travis-ci.org/rails/rails/jobs/4125097") }
  end

  describe '#status' do
    subject { super().status }
    it { is_expected.to eq('') }
  end

  it { is_expected.to eq(subject.job.annotations.first) }
end
