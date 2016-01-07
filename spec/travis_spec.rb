require 'spec_helper'

describe Travis do
  describe '#api_endpoint' do
    subject { super().api_endpoint }
    it { is_expected.to eq('https://api.travis-ci.org/') }
  end

  it 'has a nice inspect on entities' do
    skip "does not work on JRuby" if defined? RUBY_ENGINE and RUBY_ENGINE == 'jruby'
    expect(Travis::Repository.find('rails/rails').inspect).to eq("#<Travis::Repository: rails/rails>")
  end
end
