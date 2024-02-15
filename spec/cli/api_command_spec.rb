# frozen_string_literal: true

require 'spec_helper'

describe Travis::CLI::ApiCommand do
  describe 'enterprise' do
    travis_config_path = ENV['TRAVIS_CONFIG_PATH']
    subject(:api_command) { described_class.new }

    before do
      ENV['TRAVIS_CONFIG_PATH'] = File.expand_path '../support', File.dirname(__FILE__)
      config = api_command.send(:load_file, 'fake_travis_config.yml')
      api_command.config = YAML.load(config)

      api_command.api_endpoint = 'https://travis-ci-enterprise/api'
      api_command.enterprise_name = 'default'
    end

    after do
      ENV['TRAVIS_CONFIG_PATH'] = travis_config_path
    end

    describe '#setup_enterprise' do
      before do
        api_command.send(:setup_enterprise)
      end

      it 'keeps verifying peers' do
        api_command.insecure.should be_falsey
      end

      it 'uses default CAs' do
        api_command.session.ssl.should_not include(:ca_file)
      end

      it 'flags endpoint' do
        api_command.endpoint_config.should include('enterprise' => true)
      end
    end
  end
end
