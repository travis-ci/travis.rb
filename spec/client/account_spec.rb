require 'spec_helper'

describe Travis::Client::Account do
  let(:session) { Travis::Client.new }
  subject { session.accounts.first }
  its(:id) { should be == 123 }
  its(:name) { should be == 'Konstantin Haase' }
  its(:login) { should be == 'rkh' }
  its(:type) { should be == 'user' }
  its(:repos_count) { should be == 200 }
  its(:inspect) { should be == "#<Travis::Client::Account: rkh>" }
end
