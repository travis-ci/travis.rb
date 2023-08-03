# frozen_string_literal: true

require 'spec_helper'

describe Travis::Pro do
  it { is_expected.to be_a(Travis::Client::Namespace) }
  its(:api_endpoint) { is_expected.to be == 'https://api.travis-ci.com/' }

  it 'has a nice inspect on entities' do
    Travis::Pro::Repository.find('rails/rails').inspect.should be == '#<Travis::Pro::Repository: rails/rails>'
  end
end
