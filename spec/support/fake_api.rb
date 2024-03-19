# frozen_string_literal: true

require 'sinatra/base'
require 'travis/client/session'

RAILS_KEY = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnOGqjSJGeWIlTFLm5qjEIs/7l\nEx4v0LMGld6+7RwaFjIptr/slaJXPsE8gJxxaDs5aqpD2wT0IXLYw4RDhlwOYnHI\nXjlPwak+sJycfVolhY9QAJJbADD+kwjlnnDAe5QzQg1xVLusUr9QXzZ93nftb0m7\n+Lntq91SxE1r8F/+zQIDAQAB\n-----END PUBLIC KEY-----\n"

module Travis
  module Client
    class Session
      class FakeAPI < Sinatra::Base
        disable :protection
        enable :raise_errors
        set :rails_description, 'Ruby on Rails'

        before do
          content_type :json
        end

        def authorized?
          env['HTTP_AUTHORIZATION'] == 'token token'
        end

        get '/' do
          '{}'
        end

        get '/users/' do
          halt(403, 'wrong token') unless authorized?
          { 'user' =>
            { 'id' => 267,
              'name' => 'Konstantin Haase',
              'login' => 'rkh',
              'email' => 'konstantin.haase@gmail.com',
              'gravatar_id' => '5c2b452f6eea4a6d84c105ebd971d2a4',
              'locale' => 'en',
              'is_syncing' => false,
              'synced_at' => '2012-10-27T12:52:25Z',
              'correct_scopes' => true } }.to_json
        end

        get '/logout' do
          halt(403, 'wrong token') unless authorized?
          { 'user' =>
            { 'id' => 267,
              'name' => 'Konstantin Haase',
              'login' => 'rkh',
              'email' => 'konstantin.haase@gmail.com',
              'gravatar_id' => '5c2b452f6eea4a6d84c105ebd971d2a4',
              'locale' => 'en',
              'is_syncing' => false,
              'synced_at' => '2012-10-27T12:52:25Z',
              'correct_scopes' => true } }.to_json
        end

        get '/jobs/4125097' do
          { 'job' =>
            { 'id' => 4_125_097,
              'repository_id' => 891,
              'repository_slug' => 'rails/rails',
              'build_id' => 4_125_095,
              'commit_id' => 1_201_631,
              'log_id' => 3_168_319,
              'number' => '6180.2',
              'config' =>
              { 'script' => 'ci/travis.rb',
                'before_install' => ['gem install bundler'],
                'rvm' => '1.9.3',
                'env' => 'GEM=ap,am,amo,as',
                'notifications' =>
                { 'email' => false,
                  'irc' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'channels' => ['irc.freenode.org#rails-contrib'] },
                  'campfire' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'rooms' =>
                    [{ 'secure' =>
                       "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                'bundler_args' => '--path vendor/bundle',
                '.result' => 'configured' },
              'state' => 'passed',
              'started_at' => '2013-01-13T15:55:59Z',
              'finished_at' => '2013-01-13T16:11:04Z',
              'queue' => 'builds.rails',
              'allow_failure' => false,
              'tags' => '' },
            'commit' =>
            { 'id' => 1_201_631,
              'sha' => 'a0265b98f16c6e33be32aa3f57231d1189302400',
              'branch' => 'master',
              'message' => 'Associaton -> Association',
              'committed_at' => '2013-01-13T15:43:24Z',
              'author_name' => 'Steve Klabnik',
              'author_email' => 'steve@steveklabnik.com',
              'committer_name' => 'Steve Klabnik',
              'committer_email' => 'steve@steveklabnik.com',
              'compare_url' =>
              'https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c' } }.to_json
        end

        get '/builds/4125095' do
          { 'build' =>
            { 'id' => 4_125_095,
              'repository_id' => 891,
              'commit_id' => 1_201_631,
              'number' => '6180',
              'pull_request' => false,
              'config' =>
              { 'script' => 'ci/travis.rb',
                'before_install' => ['gem install bundler'],
                'rvm' => ['1.9.3', '2.0.0'],
                'env' =>
                ['GEM=railties',
                 'GEM=ap,am,amo,as',
                 'GEM=ar:mysql',
                 'GEM=ar:mysql2',
                 'GEM=ar:sqlite3',
                 'GEM=ar:postgresql'],
                'notifications' =>
                { 'email' => false,
                  'irc' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'channels' => ['irc.freenode.org#rails-contrib'] },
                  'campfire' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'rooms' =>
                    [{ 'secure' =>
                       "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                'bundler_args' => '--path vendor/bundle',
                '.result' => 'configured' },
              'state' => 'failed',
              'started_at' => '2013-01-13T15:55:17Z',
              'finished_at' => nil,
              'duration' => 5019,
              'job_ids' =>
              [4_125_096,
               4_125_097,
               4_125_098,
               4_125_099,
               4_125_100,
               4_125_101,
               4_125_102,
               4_125_103,
               4_125_104,
               4_125_105,
               4_125_106,
               4_125_107] },
            'commit' =>
            { 'id' => 1_201_631,
              'sha' => 'a0265b98f16c6e33be32aa3f57231d1189302400',
              'branch' => 'master',
              'message' => 'Associaton -> Association',
              'committed_at' => '2013-01-13T15:43:24Z',
              'author_name' => 'Steve Klabnik',
              'author_email' => 'steve@steveklabnik.com',
              'committer_name' => 'Steve Klabnik',
              'committer_email' => 'steve@steveklabnik.com',
              'compare_url' =>
              'https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c' },
            'jobs' =>
            [{ 'id' => 4_125_096,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_318,
               'state' => 'failed',
               'number' => '6180.1',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '1.9.3',
                 'env' => 'GEM=railties',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:59Z',
               'finished_at' => '2013-01-13T16:10:15Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_097,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_319,
               'state' => 'passed',
               'number' => '6180.2',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '1.9.3',
                 'env' => 'GEM=ap,am,amo,as',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:59Z',
               'finished_at' => '2013-01-13T16:11:04Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_098,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_320,
               'state' => 'passed',
               'number' => '6180.3',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '1.9.3',
                 'env' => 'GEM=ar:mysql',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:59Z',
               'finished_at' => '2013-01-13T16:08:14Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_099,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_321,
               'state' => 'passed',
               'number' => '6180.4',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '1.9.3',
                 'env' => 'GEM=ar:mysql2',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:17Z',
               'finished_at' => '2013-01-13T16:06:15Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_100,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_322,
               'state' => 'passed',
               'number' => '6180.5',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '1.9.3',
                 'env' => 'GEM=ar:sqlite3',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:58Z',
               'finished_at' => '2013-01-13T16:08:07Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_101,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_323,
               'state' => 'passed',
               'number' => '6180.6',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '1.9.3',
                 'env' => 'GEM=ar:postgresql',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:28Z',
               'finished_at' => '2013-01-13T16:08:41Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_102,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_324,
               'state' => 'failed',
               'number' => '6180.7',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '2.0.0',
                 'env' => 'GEM=railties',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:17Z',
               'finished_at' => '2013-01-13T15:56:16Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_103,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_325,
               'state' => 'failed',
               'number' => '6180.8',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '2.0.0',
                 'env' => 'GEM=ap,am,amo,as',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:58Z',
               'finished_at' => '2013-01-13T15:56:57Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_104,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_326,
               'state' => 'failed',
               'number' => '6180.9',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '2.0.0',
                 'env' => 'GEM=ar:mysql',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:18Z',
               'finished_at' => '2013-01-13T15:56:16Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_105,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_327,
               'state' => 'failed',
               'number' => '6180.10',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '2.0.0',
                 'env' => 'GEM=ar:mysql2',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:55:27Z',
               'finished_at' => '2013-01-13T15:56:23Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_106,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_328,
               'state' => 'failed',
               'number' => '6180.11',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '2.0.0',
                 'env' => 'GEM=ar:sqlite3',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:56:47Z',
               'finished_at' => '2013-01-13T15:57:43Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' },
             { 'id' => 4_125_107,
               'repository_id' => 891,
               'build_id' => 4_125_095,
               'commit_id' => 1_201_631,
               'log_id' => 3_168_329,
               'state' => 'failed',
               'number' => '6180.12',
               'config' =>
               { 'script' => 'ci/travis.rb',
                 'before_install' => ['gem install bundler'],
                 'rvm' => '2.0.0',
                 'env' => 'GEM=ar:postgresql',
                 'notifications' =>
                 { 'email' => false,
                   'irc' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'channels' => ['irc.freenode.org#rails-contrib'] },
                   'campfire' =>
                   { 'on_success' => 'change',
                     'on_failure' => 'always',
                     'rooms' =>
                     [{ 'secure' =>
                        "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                 'bundler_args' => '--path vendor/bundle',
                 '.result' => 'configured' },
               'started_at' => '2013-01-13T15:56:54Z',
               'finished_at' => '2013-01-13T15:57:49Z',
               'queue' => 'builds.rails',
               'allow_failure' => false,
               'tags' => '' }] }.to_json
        end

        get '/builds/' do
          return { 'builds' => [] }.to_json if params[:after_number]

          { 'builds' =>
            [{ 'id' => 4_125_095,
               'repository_id' => 891,
               'commit_id' => 1_201_631,
               'number' => '6180',
               'pull_request' => false,
               'config' =>
              { 'script' => 'ci/travis.rb',
                'before_install' => ['gem install bundler'],
                'rvm' => ['1.9.3', '2.0.0'],
                'env' =>
                ['GEM=railties',
                 'GEM=ap,am,amo,as',
                 'GEM=ar:mysql',
                 'GEM=ar:mysql2',
                 'GEM=ar:sqlite3',
                 'GEM=ar:postgresql'],
                'notifications' =>
                { 'email' => false,
                  'irc' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'channels' => ['irc.freenode.org#rails-contrib'] },
                  'campfire' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'rooms' =>
                    [{ 'secure' =>
                       "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                'bundler_args' => '--path vendor/bundle',
                '.result' => 'configured' },
               'state' => 'failed',
               'started_at' => '2013-01-13T15:55:17Z',
               'finished_at' => nil,
               'duration' => 5019,
               'job_ids' =>
              [4_125_096,
               4_125_097,
               4_125_098,
               4_125_099,
               4_125_100,
               4_125_101,
               4_125_102,
               4_125_103,
               4_125_104,
               4_125_105,
               4_125_106,
               4_125_107] }],
            'commits' =>
            [{ 'id' => 1_201_631,
               'sha' => 'a0265b98f16c6e33be32aa3f57231d1189302400',
               'branch' => 'master',
               'message' => 'Associaton -> Association',
               'committed_at' => '2013-01-13T15:43:24Z',
               'author_name' => 'Steve Klabnik',
               'author_email' => 'steve@steveklabnik.com',
               'committer_name' => 'Steve Klabnik',
               'committer_email' => 'steve@steveklabnik.com',
               'compare_url' =>
              'https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c' }] }.to_json
        end

        get '/jobs/4125096' do
          { 'job' =>
            { 'id' => 4_125_096,
              'repository_id' => 891,
              'repository_slug' => 'rails/rails',
              'build_id' => 4_125_095,
              'commit_id' => 1_201_631,
              'log_id' => 3_168_318,
              'number' => '6180.1',
              'config' =>
              { 'script' => 'ci/travis.rb',
                'before_install' => ['gem install bundler'],
                'rvm' => '1.9.3',
                'env' => 'GEM=railties',
                'notifications' =>
                { 'email' => false,
                  'irc' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'channels' => ['irc.freenode.org#rails-contrib'] },
                  'campfire' =>
                  { 'on_success' => 'change',
                    'on_failure' => 'always',
                    'rooms' =>
                    [{ 'secure' =>
                       "YA1alef1ESHWGFNVwvmVGCkMe4cUy4j+UcNvMUESraceiAfVyRMAovlQBGs6\n9kBRm7DHYBUXYC2ABQoJbQRLDr/1B5JPf/M8+Qd7BKu8tcDC03U01SMHFLpO\naOs/HLXcDxtnnpL07tGVsm0zhMc5N8tq4/L3SHxK7Vi+TacwQzI=" }] } },
                'bundler_args' => '--path vendor/bundle',
                '.result' => 'configured' },
              'state' => 'failed',
              'started_at' => '2013-01-13T15:55:59Z',
              'finished_at' => '2013-01-13T16:10:15Z',
              'queue' => 'builds.rails',
              'allow_failure' => false,
              'tags' => '' },
            'commit' =>
            { 'id' => 1_201_631,
              'sha' => 'a0265b98f16c6e33be32aa3f57231d1189302400',
              'branch' => 'master',
              'message' => 'Associaton -> Association',
              'committed_at' => '2013-01-13T15:43:24Z',
              'author_name' => 'Steve Klabnik',
              'author_email' => 'steve@steveklabnik.com',
              'committer_name' => 'Steve Klabnik',
              'committer_email' => 'steve@steveklabnik.com',
              'compare_url' =>
              'https://github.com/rails/rails/compare/6581d798e830...a0265b98f16c' } }.to_json
        end

        get '/repos/' do
          { 'repos' =>
            [{ 'id' => 107_495,
               'slug' => 'pypug/django-mango',
               'description' => 'More Mango, less Django!',
               'last_build_id' => 4_125_823,
               'last_build_number' => '39',
               'last_build_state' => 'failed',
               'last_build_duration' => 31,
               'last_build_language' => nil,
               'last_build_started_at' => '2013-01-13T16:58:43Z',
               'last_build_finished_at' => '2013-01-13T16:55:08Z' }] }.to_json
        end

        get '/config' do
          { 'config' => { 'host' => 'travis-ci.org' } }.to_json
        end

        get '/logs/3168318' do
          { 'log' =>
            { 'id' => 3_168_318,
              'job_id' => 4_125_096,
              'type' => 'Log',
              'body' =>
              "$ export GEM=railties\n" } }.to_json
        end

        get '/repos/*/travis.rb' do
          # HACK: hack
          request.path_info = '/repos/rails/rails'
          pass
        end

        get '/repos/891' do
          request.path_info = '/repos/rails/rails'
          pass
        end

        get '/repos/rails/rails' do
          { 'repo' =>
            { 'id' => 891,
              'slug' => 'rails/rails',
              'description' => settings.rails_description,
              'last_build_id' => 4_125_095,
              'last_build_number' => '6180',
              'last_build_state' => 'failed',
              'last_build_duration' => 5019,
              'last_build_language' => nil,
              'last_build_started_at' => '2013-01-13T15:55:17Z',
              'last_build_finished_at' => nil,
              'github_language' => 'Ruby' } }.to_json
        end

        get '/repos/891/key' do
          { 'key' => RAILS_KEY, 'fingerprint' => 'foobar' }.to_json
        end

        get '/accounts/' do
          { 'accounts' =>
          [{ 'name' => 'Konstantin Haase',
             'login' => 'rkh',
             'type' => 'user',
             'repos_count' => 200 }] }.to_json
        end

        get '/broadcasts/' do
          { 'broadcasts' =>
          [{ 'id' => 1,
             'message' => 'Hello!' }] }.to_json
        end

        #### for encrypt_file spec
        get '/settings/env_vars/' do
          # p params
          $params = params
          {
            "env_vars": [
              {
                "id": '8aa1c74d-dcc4-4e41-9087-1326b7c68abd',
                "name": 'encrypted_randomhex_key',
                "value": 'super_secret_key',
                "public": false,
                "repository_id": 891
              },
              {
                "id": 'b2ed30b9-622d-4bd7-928b-ba5aad7ba6a1',
                "name": 'encrypted_randomhex_iv',
                "value": 'super_secret_iv',
                "public": false,
                "repository_id": 891
              }
            ]
          }.to_json
        end

        patch '/settings/env_vars/8aa1c74d-dcc4-4e41-9087-1326b7c68abd' do
          $params = params
          {
            "env_var": {
              "id": '8aa1c74d-dcc4-4e41-9087-1326b7c68abd',
              "name": 'encrypted_randomhex_key',
              "value": 'new_super_secret_key',
              "public": false,
              "repository_id": 891
            }
          }.to_json
        end

        patch '/settings/env_vars/b2ed30b9-622d-4bd7-928b-ba5aad7ba6a1' do
          $params = params
          {
            "env_var": {
              "id": 'b2ed30b9-622d-4bd7-928b-ba5aad7ba6a1',
              "name": 'encrypted_randomhex_iv',
              "value": 'new_super_secret_iv',
              "public": false,
              "repository_id": 891
            }
          }.to_json
        end

        post '/:entity/:id/restart' do
          $params = params
          {}
        end

        post '/:entity/:id/cancel' do
          $params = params
          {}
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
