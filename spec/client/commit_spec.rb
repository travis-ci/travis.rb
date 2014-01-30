require 'spec_helper'

describe Travis::Client::Build do
  let(:session) { Travis::Client.new }
  subject { session.build(4125095).commit }

  its(:sha) { should be == 'a0265b98f16c6e33be32aa3f57231d1189302400' }
  its(:short_sha) { should be == 'a0265b9' }
  its(:branch) { should be == 'master' }
  its(:message) { should be == 'Associaton -> Association' }
  its(:committed_at) { should be_a(Time) }
  its(:author_name) { should be == 'Steve Klabnik' }
  its(:author_email) { should be == 'steve@steveklabnik.com' }
  its(:committer_name) { should be == 'Steve Klabnik' }
  its(:committer_email) { should be == 'steve@steveklabnik.com' }
  its(:compare_url) { should be == 'https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c' }
  its(:subject) { should be == 'Associaton -> Association' }

  specify "with missing data" do
    session.load("commit" => { "id" => 12 })['commit'].subject.should be_empty
  end
end
