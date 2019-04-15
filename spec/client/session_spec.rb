require 'spec_helper'

describe Travis::Client::Session do
  it { should be_a(Travis::Client::Methods) }

  describe "uri" do
    its(:uri) { should be == "https://api.travis-ci.org/" }

    it 'can be set as argument' do
      Travis::Client::Session.new('http://foo/').uri.should be == 'http://foo/'
    end

    it 'can be set as hash argument' do
      Travis::Client::Session.new(:uri => 'http://foo/').uri.should be == 'http://foo/'
    end
  end

  describe "access_token" do
    its(:access_token) { should be_nil }

    it 'gives authenticated access if set' do
      subject.access_token = 'token'
      subject.user.login.should be == 'rkh'
    end

    it 'raises if token is not set' do
      expect { subject.user.login }.to raise_error(Travis::Client::Error)
    end
  end

  describe "connection" do
    its(:connection) { should be_a(Faraday::Connection) }

    it 'creates a new connection when changing the uri' do
      old_connection = subject.connection
      subject.uri    = 'http://localhost:3000'
      subject.connection.should_not be == old_connection
    end
  end

  describe "headers" do
    it 'propagates headers to connection headers' do
      subject.headers['foo'] = 'bar'
      subject.connection.headers.should include('foo')
    end

    it 'propagates headers to new connections' do
      subject.headers['foo'] = 'bar'
      subject.connection = Faraday::Connection.new
      subject.connection.headers.should include('foo')
    end

    it 'is possible to set headers as constructor option' do
      Travis::Client::Session.new(:headers => {'foo' => 'bar'}, :uri => 'http://localhost:3000/').
        connection.headers['foo'].should be == 'bar'
    end

    it 'sets a User-Agent' do
      subject.headers['User-Agent'].should include("Travis/#{Travis::VERSION}")
      subject.headers['User-Agent'].should include("Faraday/#{Faraday::VERSION}")
      subject.headers['User-Agent'].should include("Rack/#{Rack.version}")
      subject.headers['User-Agent'].should include("Ruby #{RUBY_VERSION}")
    end

    it 'allows adding custom info to the User-Agent' do
      subject.agent_info = "foo"
      subject.headers['User-Agent'].should include("foo")
      subject.headers['User-Agent'].should include("Travis/#{Travis::VERSION}")
      subject.headers['User-Agent'].should include("Faraday/#{Faraday::VERSION}")
      subject.headers['User-Agent'].should include("Rack/#{Rack.version}")
      subject.headers['User-Agent'].should include("Ruby #{RUBY_VERSION}")
    end
  end

  describe "find_one" do
    it 'finds one instance' do
      repo = subject.find_one(Travis::Client::Repository, 'rails/rails')
      repo.should be_a(Travis::Client::Repository)
      repo.slug.should be == 'rails/rails'
    end
  end

  describe "find_many" do
    it 'finds many instances' do
      repos = subject.find_many(Travis::Client::Repository)
      repos.should be_an(Array)
      repos.each { |repo| repo.should be_a(Travis::Client::Repository) }
      repos.first.slug.should be == "pypug/django-mango"
    end
  end

  describe "find_one_or_many" do
    it 'finds one instance' do
      subject.access_token = 'token'
      subject.find_one_or_many(Travis::Client::User).should be_a(Travis::Client::User)
    end

    it 'finds many instances' do
      subject.find_one_or_many(Travis::Client::Repository).should be_an(Array)
    end
  end

  describe "reload" do
    it 'reloads an instance' do
      Travis::Client::Session::FakeAPI.rails_description = "Ruby on Rails"
      rails = subject.find_one(Travis::Client::Repository, 'rails/rails')
      rails.description.should be == 'Ruby on Rails'
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      rails.description.should be == 'Ruby on Rails'
      subject.reload(rails)
      rails.description.should be == 'Rails on the Rubies'
    end
  end

  describe "get" do
    it 'fetches a payload and substitutes values with entities' do
      result = subject.get('/repos/')
      result['repos'].first.slug.should be == "pypug/django-mango"
    end
  end

  describe "clear_cache" do
    it 'resets all the entities' do
      Travis::Client::Session::FakeAPI.rails_description = "Ruby on Rails"
      rails = subject.find_one(Travis::Client::Repository, 'rails/rails')
      rails.description.should be == 'Ruby on Rails'
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      rails.description.should be == 'Ruby on Rails'
      subject.clear_cache
      rails.description.should be == 'Rails on the Rubies'
    end

    it 'keeps entries in the identity map' do
      rails = subject.repo('rails/rails')
      subject.clear_cache
      subject.repo('rails/rails').should be_equal(rails)
    end
  end

  describe "clear_cache!" do
    it 'resets all the entities' do
      Travis::Client::Session::FakeAPI.rails_description = "Ruby on Rails"
      rails = subject.find_one(Travis::Client::Repository, 'rails/rails')
      rails.description.should be == 'Ruby on Rails'
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      rails.description.should be == 'Ruby on Rails'
      subject.clear_cache!
      rails.description.should be == 'Rails on the Rubies'
    end

    it 'does not keep entries in the identity map' do
      rails = subject.repo('rails/rails')
      subject.clear_cache!
      subject.repo('rails/rails').should_not be_equal(rails)
    end
  end

  describe "session" do
    its(:session) { should eq(subject) }
  end

  describe "config" do
    its(:config) { should be == {"host" => "travis-ci.org"}}
  end
end
