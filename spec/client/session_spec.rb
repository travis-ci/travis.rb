require 'spec_helper'

describe Travis::Client::Session do
  it { is_expected.to be_a(Travis::Client::Methods) }

  describe "uri" do
    describe '#uri' do
      subject { super().uri }
      it { is_expected.to eq("https://api.travis-ci.org/") }
    end

    it 'can be set as argument' do
      expect(Travis::Client::Session.new('http://foo/').uri).to eq('http://foo/')
    end

    it 'can be set as hash argument' do
      expect(Travis::Client::Session.new(:uri => 'http://foo/').uri).to eq('http://foo/')
    end
  end

  describe "access_token" do
    describe '#access_token' do
      subject { super().access_token }
      it { is_expected.to be_nil }
    end

    it 'gives authenticated access if set' do
      subject.access_token = 'token'
      expect(subject.user.login).to eq('rkh')
    end

    it 'raises if token is not set' do
      expect { subject.user.login }.to raise_error(Travis::Client::Error)
    end
  end

  describe "connection" do
    describe '#connection' do
      subject { super().connection }
      it { is_expected.to be_a(Faraday::Connection) }
    end

    it 'creates a new connection when changing the uri' do
      old_connection = subject.connection
      subject.uri    = 'http://localhost:3000'
      expect(subject.connection).not_to eq(old_connection)
    end
  end

  describe "headers" do
    it 'propagates headers to connection headers' do
      subject.headers['foo'] = 'bar'
      expect(subject.connection.headers).to include('foo')
    end

    it 'propagates headers to new connections' do
      subject.headers['foo'] = 'bar'
      subject.connection = Faraday::Connection.new
      expect(subject.connection.headers).to include('foo')
    end

    it 'is possible to set headers as constructor option' do
      expect(Travis::Client::Session.new(:headers => {'foo' => 'bar'}, :uri => 'http://localhost:3000/').
        connection.headers['foo']).to eq('bar')
    end

    it 'sets a User-Agent' do
      expect(subject.headers['User-Agent']).to include("Travis/#{Travis::VERSION}")
      expect(subject.headers['User-Agent']).to include("Faraday/#{Faraday::VERSION}")
      expect(subject.headers['User-Agent']).to include("Rack/#{Rack.version}")
      expect(subject.headers['User-Agent']).to include("Ruby #{RUBY_VERSION}")
    end

    it 'allows adding custom infos to the User-Agent' do
      subject.agent_info = "foo"
      expect(subject.headers['User-Agent']).to include("foo")
      expect(subject.headers['User-Agent']).to include("Travis/#{Travis::VERSION}")
      expect(subject.headers['User-Agent']).to include("Faraday/#{Faraday::VERSION}")
      expect(subject.headers['User-Agent']).to include("Rack/#{Rack.version}")
      expect(subject.headers['User-Agent']).to include("Ruby #{RUBY_VERSION}")
    end
  end

  describe "find_one" do
    it 'finds one instance' do
      repo = subject.find_one(Travis::Client::Repository, 'rails/rails')
      expect(repo).to be_a(Travis::Client::Repository)
      expect(repo.slug).to eq('rails/rails')
    end
  end

  describe "find_many" do
    it 'finds many instances' do
      repos = subject.find_many(Travis::Client::Repository)
      expect(repos).to be_an(Array)
      repos.each { |repo| expect(repo).to be_a(Travis::Client::Repository) }
      expect(repos.first.slug).to eq("pypug/django-mango")
    end
  end

  describe "find_one_or_many" do
    it 'finds one instance' do
      subject.access_token = 'token'
      expect(subject.find_one_or_many(Travis::Client::User)).to be_a(Travis::Client::User)
    end

    it 'finds many instances' do
      expect(subject.find_one_or_many(Travis::Client::Repository)).to be_an(Array)
    end
  end

  describe "reload" do
    it 'reloads an instance' do
      Travis::Client::Session::FakeAPI.rails_description = "Ruby on Rails"
      rails = subject.find_one(Travis::Client::Repository, 'rails/rails')
      expect(rails.description).to eq('Ruby on Rails')
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      expect(rails.description).to eq('Ruby on Rails')
      subject.reload(rails)
      expect(rails.description).to eq('Rails on the Rubies')
    end
  end

  describe "get" do
    it 'fetches a payload and substitutes values with entities' do
      result = subject.get('/repos/')
      expect(result['repos'].first.slug).to eq("pypug/django-mango")
    end
  end

  describe "clear_cache" do
    it 'resets all the entities' do
      Travis::Client::Session::FakeAPI.rails_description = "Ruby on Rails"
      rails = subject.find_one(Travis::Client::Repository, 'rails/rails')
      expect(rails.description).to eq('Ruby on Rails')
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      expect(rails.description).to eq('Ruby on Rails')
      subject.clear_cache
      expect(rails.description).to eq('Rails on the Rubies')
    end

    it 'keeps entries in the identity map' do
      rails = subject.repo('rails/rails')
      subject.clear_cache
      expect(subject.repo('rails/rails')).to be_equal(rails)
    end
  end

  describe "clear_cache!" do
    it 'resets all the entities' do
      Travis::Client::Session::FakeAPI.rails_description = "Ruby on Rails"
      rails = subject.find_one(Travis::Client::Repository, 'rails/rails')
      expect(rails.description).to eq('Ruby on Rails')
      Travis::Client::Session::FakeAPI.rails_description = 'Rails on the Rubies'
      expect(rails.description).to eq('Ruby on Rails')
      subject.clear_cache!
      expect(rails.description).to eq('Rails on the Rubies')
    end

    it 'does not keep entries in the identity map' do
      rails = subject.repo('rails/rails')
      subject.clear_cache!
      expect(subject.repo('rails/rails')).not_to be_equal(rails)
    end
  end

  describe "session" do
    describe '#session' do
      subject { super().session }
      it { is_expected.to eq(subject) }
    end
  end

  describe "config" do
    describe '#config' do
      subject { super().config }
      it { is_expected.to eq({"host" => "travis-ci.org"})}
    end
  end
end
