# frozen_string_literal: true

require 'travis/client/auto_login'
require 'spec_helper'

describe Travis::Client::AutoLogin do
  let(:auto_login_with_token) { described_class.new(Travis::Client.new, { config_file: travis_config }) }
  let(:auto_login_without_token) { described_class.new(Travis::Client.new) }
  let(:travis_config) { File.expand_path('../support/fake_travis_config.yml', File.dirname(__FILE__)) }

  context 'when user authenticates' do
    context 'when user has a token in cli config' do
      it 'does not call Tools::Github#with_token' do
        expect_any_instance_of(Travis::Tools::Github).not_to receive(:with_token)
        auto_login_with_token.authenticate
      end
    end

    context 'when user does not have a token in cli config' do
      before { auto_login_without_token.github.stub(:with_token).and_return(true) }

      it 'calls Tools::Github#with_token' do
        expect(auto_login_without_token.github).to receive(:with_token)
        auto_login_without_token.authenticate
      end
    end
  end
end
