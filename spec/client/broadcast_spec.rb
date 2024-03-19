# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Broadcast do
  subject { session.broadcasts.first }

  let(:session) { Travis::Client.new }

  its(:id) { is_expected.to be == 1 }
  its(:message) { is_expected.to be == 'Hello!' }
end
