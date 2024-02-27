# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Build do
  subject { session.build(4_125_095).commit }

  let(:session) { Travis::Client.new }

  its(:sha) { is_expected.to be == 'a0265b98f16c6e33be32aa3f57231d1189302400' }
  its(:short_sha) { is_expected.to be == 'a0265b9' }
  its(:branch) { is_expected.to be == 'master' }
  its(:message) { is_expected.to be == 'Associaton -> Association' }
  its(:committed_at) { is_expected.to be_a(Time) }
  its(:author_name) { is_expected.to be == 'Steve Klabnik' }
  its(:author_email) { is_expected.to be == 'steve@steveklabnik.com' }
  its(:committer_name) { is_expected.to be == 'Steve Klabnik' }
  its(:committer_email) { is_expected.to be == 'steve@steveklabnik.com' }
  its(:compare_url) { is_expected.to be == 'https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c' }
  its(:subject) { is_expected.to be == 'Associaton -> Association' }

  specify 'with missing data' do
    session.load('commit' => { 'id' => 12 })['commit'].subject.should be_empty
  end
end
