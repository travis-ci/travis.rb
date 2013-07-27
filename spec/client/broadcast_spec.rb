require 'spec_helper'

describe Travis::Client::Broadcast do
  let(:session) { Travis::Client.new }
  subject { session.broadcasts.first }

  its(:id) { should be == 1 }
  its(:message) { should be == "Hello!" }

end
