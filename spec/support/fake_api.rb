require 'sinatra/base'
require 'travis/client/session'

module Travis
  module Client
    class Session
      class FakeAPI < Sinatra::Base
        disable :protection
        set(:rails_description, "Ruby on Rails")

        before do
          content_type :json
        end

        def authorized?
          env['HTTP_AUTHORIZATION'] == 'token token'
        end

        get '/users/' do
          halt(403, 'wrong token') unless authorized?
          {"user"=>
            {"id"=>267,
             "name"=>"Konstantin Haase",
             "login"=>"rkh",
             "email"=>"konstantin.haase@gmail.com",
             "gravatar_id"=>"5c2b452f6eea4a6d84c105ebd971d2a4",
             "locale"=>"en",
             "is_syncing"=>false,
             "synced_at"=>"2012-10-27T12:52:25Z",
             "correct_scopes"=>true}}.to_json
        end

        get '/repos/' do
          {"repos"=>
            [{"id"=>107495,
              "slug"=>"pypug/django-mango",
              "description"=>"More Mango, less Django!",
              "last_build_id"=>4125823,
              "last_build_number"=>"39",
              "last_build_state"=>"failed",
              "last_build_duration"=>31,
              "last_build_language"=>nil,
              "last_build_started_at"=>"2013-01-13T16:58:43Z",
              "last_build_finished_at"=>"2013-01-13T16:55:08Z"}]}.to_json
        end

        get '/repos/891' do
          request.path_info = '/repos/rails/rails'
          pass
        end

        get '/repos/rails/rails' do
          {"repo"=>
            {"id"=>891,
             "slug"=>"rails/rails",
             "description"=>settings.rails_description,
             "last_build_id"=>4125095,
             "last_build_number"=>"6180",
             "last_build_state"=>"failed",
             "last_build_duration"=>5019,
             "last_build_language"=>nil,
             "last_build_started_at"=>"2013-01-13T15:55:17Z",
             "last_build_finished_at"=>nil}}.to_json
        end

        post '/auth/github' do
          halt(403) unless params[:github_token] == 'github_token'
          { 'access_token' => 'token' }.to_json
        end
      end

      def faraday_adapter
        [:rack, FakeAPI.new]
      end
    end
  end
end
