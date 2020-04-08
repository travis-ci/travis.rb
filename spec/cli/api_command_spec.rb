require 'spec_helper'

describe Travis::CLI::ApiCommand do
  describe 'enterprise' do
    travis_config_path = ENV['TRAVIS_CONFIG_PATH']

    before do
      ENV['TRAVIS_CONFIG_PATH'] = File.expand_path '../support', File.dirname(__FILE__)
      config = subject.send(:load_file, 'fake_travis_config.yml')
      subject.config = YAML.load(config)

      subject.api_endpoint = 'https://travis-ci-enterprise/api'
      subject.enterprise_name = 'default'
    end

    after do
      ENV['TRAVIS_CONFIG_PATH'] = travis_config_path
    end

    describe '#setup_enterprise' do
      before do
        subject.send(:setup_enterprise)
      end

      it 'keeps verifying peers' do
        subject.insecure.should be_falsey
      end

      it 'uses default CAs' do
        subject.session.ssl.should_not include(:ca_file)
      end

      it 'flags endpoint' do
        subject.endpoint_config.should include('enterprise' => true)
      end
    end
  end
end
