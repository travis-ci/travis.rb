require 'spec_helper'

describe Travis::Client::Account do
  context "from all accounts" do
    let(:session) { Travis::Client.new }
    subject { session.accounts.first }

    describe '#name' do
      subject { super().name }
      it { is_expected.to eq('Konstantin Haase') }
    end

    describe '#login' do
      subject { super().login }
      it { is_expected.to eq('rkh') }
    end

    describe '#type' do
      subject { super().type }
      it { is_expected.to eq('user') }
    end

    describe '#repos_count' do
      subject { super().repos_count }
      it { is_expected.to eq(200) }
    end

    describe '#inspect' do
      subject { super().inspect }
      it { is_expected.to eq("#<Travis::Client::Account: rkh>") }
    end
  end

  context "known account" do
    let(:session) { Travis::Client.new }
    subject { session.account('rkh') }

    describe '#name' do
      subject { super().name }
      it { is_expected.to eq('Konstantin Haase') }
    end

    describe '#login' do
      subject { super().login }
      it { is_expected.to eq('rkh') }
    end

    describe '#type' do
      subject { super().type }
      it { is_expected.to eq('user') }
    end

    describe '#repos_count' do
      subject { super().repos_count }
      it { is_expected.to eq(200) }
    end

    describe '#inspect' do
      subject { super().inspect }
      it { is_expected.to eq("#<Travis::Client::Account: rkh>") }
    end
  end

  context "known account" do
    let(:session) { Travis::Client.new }
    subject { session.account('foo') }

    describe '#name' do
      subject { super().name }
      it { is_expected.to be_nil }
    end

    describe '#login' do
      subject { super().login }
      it { is_expected.to eq('foo') }
    end

    describe '#type' do
      subject { super().type }
      it { is_expected.to be_nil }
    end

    describe '#inspect' do
      subject { super().inspect }
      it { is_expected.to eq("#<Travis::Client::Account: foo>") }
    end
  end
end
