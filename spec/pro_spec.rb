require 'spec_helper'

describe Travis::Pro do
  it { is_expected.to be_a(Travis::Client::Namespace) }

  describe '#api_endpoint' do
    subject { super().api_endpoint }
    it { is_expected.to eq('https://api.travis-ci.com/') }
  end

  it 'has a nice inspect on entities' do
    expect(Travis::Pro::Repository.find('rails/rails').inspect).to eq("#<Travis::Pro::Repository: rails/rails>")
  end
end
