# frozen_string_literal: true

require 'spec_helper'

describe Travis do
  its(:api_endpoint) { is_expected.to be == 'https://api.travis-ci.com/' }

  it 'has a nice inspect on entities' do
    pending 'does not work on JRuby' if defined? RUBY_ENGINE and RUBY_ENGINE == 'jruby'
    Travis::Repository.find('rails/rails').inspect.should be == '#<Travis::Repository: rails/rails>'
  end
end
