require 'spec_helper'

describe Travis do
  its(:api_endpoint) { should be == 'https://api.travis-ci.org/' }

  it 'has a nice inspect on entities' do
    pending "does not work on JRuby" if defined? RUBY_ENGINE and RUBY_ENGINE == 'jruby'
    Travis::Repository.find('rails/rails').inspect.should be == "#<Travis::Repository: rails/rails>"
  end
end
