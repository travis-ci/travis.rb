require 'spec_helper'

describe Travis::Client::Repository do
  subject { Travis::Client.new.repo('rails/rails') }
  its(:slug) { should be == 'rails/rails' }
  its(:description) { should_not be_empty }
  its(:last_build_id) { should be == 4125095 }
  its(:last_build_number) { should be == '6180' }
  its(:last_build_state) { should be == 'failed' }
  its(:last_build_duration) { should be == 5019 }
  its(:last_build_started_at) { should be_a(Time) }
  its(:last_build_finished_at) { should be_nil }
  its(:inspect) { should be == "#<Travis::Client::Repository: rails/rails>" }
  its(:key) { should be_a(Travis::Client::Repository::Key) }
end
