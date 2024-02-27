# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Account do
  context 'with all accounts' do
    subject { session.accounts.first }

    let(:session) { Travis::Client.new }

    its(:name) { is_expected.to be == 'Konstantin Haase' }
    its(:login) { is_expected.to be == 'rkh' }
    its(:type) { is_expected.to be == 'user' }
    its(:repos_count) { is_expected.to be == 200 }
    its(:inspect) { is_expected.to be == '#<Travis::Client::Account: rkh>' }
  end

  context 'with known account' do
    subject { session.account('rkh') }

    let(:session) { Travis::Client.new }

    its(:name) { is_expected.to be == 'Konstantin Haase' }
    its(:login) { is_expected.to be == 'rkh' }
    its(:type) { is_expected.to be == 'user' }
    its(:repos_count) { is_expected.to be == 200 }
    its(:inspect) { is_expected.to be == '#<Travis::Client::Account: rkh>' }
  end

  context 'with known account and nil name' do
    subject { session.account('foo') }

    let(:session) { Travis::Client.new }

    its(:name) { is_expected.to be_nil }
    its(:login) { is_expected.to be == 'foo' }
    its(:type) { is_expected.to be_nil }
    its(:inspect) { is_expected.to be == '#<Travis::Client::Account: foo>' }
  end
end
