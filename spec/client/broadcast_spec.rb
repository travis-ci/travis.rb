require 'spec_helper'

describe Travis::Client::Broadcast do
  let(:session) { Travis::Client.new }
  subject { session.broadcasts.first }

  describe '#id' do
    subject { super().id }
    it { is_expected.to eq(1) }
  end

  describe '#message' do
    subject { super().message }
    it { is_expected.to eq("Hello!") }
  end

end
