# frozen_string_literal: true

require 'spec_helper'

describe Travis::Client::Session do
  subject(:session) { described_class.new }

  it { is_expected.to be_a(Travis::Client::Methods) }

  describe 'uri' do
    its(:uri) { is_expected.to be == 'https://api.travis-ci.com/' }

    it 'can be set as argument' do
      described_class.new('http://foo/').uri.should be == 'http://foo/'
    end

    it 'can be set as hash argument' do
      described_class.new(uri: 'http://foo/').uri.should be == 'http://foo/'
    end
  end

  describe 'access_token' do
    its(:access_token) { is_expected.to be_nil }

    it 'gives authenticated access if set' do
      session.access_token = 'token'
      session.user.login.should be == 'rkh'
    end

    it 'raises if token is not set' do
      expect { session.user.login }.to raise_error(Travis::Client::Error)
    end
  end

  describe 'connection' do
    its(:connection) { is_expected.to be_a(Faraday::Connection) }

    it 'creates a new connection when changing the uri' do
      old_connection = session.connection
      session.uri    = 'http://localhost:3000'
      session.connection.should_not be == old_connection
    end
  end

  describe 'headers' do
    it 'propagates headers to connection headers' do
      session.headers['foo'] = 'bar'
      session.connection.headers.should include('foo')
    end

    it 'propagates headers to new connections' do
      session.headers['foo'] = 'bar'
      session.connection = Faraday::Connection.new
      session.connection.headers.should include('foo')
    end

    it 'is possible to set headers as constructor option' do
      described_class.new(headers: { 'foo' => 'bar' }, uri: 'http://localhost:3000/')
                     .connection.headers['foo'].should be == 'bar'
    end

    it 'sets a User-Agent' do
      session.headers['User-Agent'].should include("Travis/#{Travis::VERSION}")
      session.headers['User-Agent'].should include("Faraday/#{Faraday::VERSION}")
      session.headers['User-Agent'].should include("Rack/#{Rack.version}")
      session.headers['User-Agent'].should include("Ruby #{RUBY_VERSION}")
    end

    it 'allows adding custom info to the User-Agent' do
      session.agent_info = 'foo'
      session.headers['User-Agent'].should include('foo')
      session.headers['User-Agent'].should include("Travis/#{Travis::VERSION}")
      session.headers['User-Agent'].should include("Faraday/#{Faraday::VERSION}")
      session.headers['User-Agent'].should include("Rack/#{Rack.version}")
      session.headers['User-Agent'].should include("Ruby #{RUBY_VERSION}")
    end
  end

  describe 'find_one' do
    it 'finds one instance' do
      repo = session.find_one(Travis::Client::Repository, 'rails/rails')
      repo.should be_a(Travis::Client::Repository)
      repo.slug.should be == 'rails/rails'
    end
  end

  describe 'find_many' do
    it 'finds many instances' do
      repos = session.find_many(Travis::Client::Repository)
      repos.should be_an(Array)
      repos.each { |repo| repo.should be_a(Travis::Client::Repository) }
      repos.first.slug.should be == 'pypug/django-mango'
    end
  end

  describe 'find_one_or_many' do
    it 'finds one instance' do
      session.access_token = 'token'
      session.find_one_or_many(Travis::Client::User).should be_a(Travis::Client::User)
    end

    it 'finds many instances' do
      session.find_one_or_many(Travis::Client::Repository).should be_an(Array)
    end
  end

  describe 'reload' do
    it 'reloads an instance' do
      Travis::Client::Session::FakeAPI.rails_description = 'Ruby on Rails'
      rails = session.find_one(Travis::Client::Repository, 'rails/rails')
      rails.description.should be == 'Ruby on Rails'
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      rails.description.should be == 'Ruby on Rails'
      session.reload(rails)
      rails.description.should be == 'Rails on the Rubies'
    end
  end

  describe 'get' do
    it 'fetches a payload and substitutes values with entities' do
      result = session.get('/repos/')
      result['repos'].first.slug.should be == 'pypug/django-mango'
    end
  end

  describe 'clear_cache' do
    it 'resets all the entities' do
      Travis::Client::Session::FakeAPI.rails_description = 'Ruby on Rails'
      rails = session.find_one(Travis::Client::Repository, 'rails/rails')
      rails.description.should be == 'Ruby on Rails'
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      rails.description.should be == 'Ruby on Rails'
      session.clear_cache
      rails.description.should be == 'Rails on the Rubies'
    end

    it 'keeps entries in the identity map' do
      rails = session.repo('rails/rails')
      session.clear_cache
      session.repo('rails/rails').should be_equal(rails)
    end
  end

  describe 'clear_cache!' do
    it 'resets all the entities' do
      Travis::Client::Session::FakeAPI.rails_description = 'Ruby on Rails'
      rails = session.find_one(Travis::Client::Repository, 'rails/rails')
      rails.description.should be == 'Ruby on Rails'
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      rails.description.should be == 'Ruby on Rails'
      session.clear_cache!
      rails.description.should be == 'Rails on the Rubies'
    end

    it 'does not keep entries in the identity map' do
      rails = session.repo('rails/rails')
      session.clear_cache!
      session.repo('rails/rails').should_not be_equal(rails)
    end
  end

  describe 'session' do
    its(:session) { is_expected.to eq(session) }
  end

  describe 'config' do
    its(:config) { is_expected.to be == { 'host' => 'travis-ci.com' } }
  end
end
