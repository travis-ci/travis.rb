require 'spec_helper'

describe Travis::Client::Account do
  context "from all accounts" do
    let(:session) { Travis::Client.new }
    subject { session.accounts.first }
    its(:name) { should be == 'Konstantin Haase' }
    its(:login) { should be == 'rkh' }
    its(:type) { should be == 'user' }
    its(:repos_count) { should be == 200 }
    its(:inspect) { should be == "#<Travis::Client::Account: rkh>" }
  end

  context "known account" do
    let(:session) { Travis::Client.new }
    subject { session.account('rkh') }
    its(:name) { should be == 'Konstantin Haase' }
    its(:login) { should be == 'rkh' }
    its(:type) { should be == 'user' }
    its(:repos_count) { should be == 200 }
    its(:inspect) { should be == "#<Travis::Client::Account: rkh>" }
  end

  context "known account" do
    let(:session) { Travis::Client.new }
    subject { session.account('foo') }
    its(:name) { should be_nil }
    its(:login) { should be == 'foo' }
    its(:type) { should be_nil }
    its(:inspect) { should be == "#<Travis::Client::Account: foo>" }
  end
end
