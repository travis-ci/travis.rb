# Run `rake travis.gemspec` to update the gemspec.
Gem::Specification.new do |s|
  # general infos
  s.name        = "travis"
  s.version     = "1.1.1"
  s.description = "CLI and Ruby client library for Travis CI"
  s.homepage    = "https://github.com/travis-ci/travis"
  s.summary     = "Travis CI client"
  s.license     = "MIT"
  s.executables = ["travis"]

  # generated from git shortlog -sn
  s.authors = [
    "Konstantin Haase",
    "Henrik Hodne",
    "Adrien Brault",
    "Piotr Sarnacki"
  ]

  # generated from git shortlog -sne
  s.email = [
    "konstantin.mailinglists@googlemail.com",
    "me@henrikhodne.com",
    "adrien.brault@gmail.com",
    "drogus@gmail.com"
  ]

  # generated from git ls-files
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "bin/travis",
    "example/org_overview.rb",
    "lib/travis.rb",
    "lib/travis/cacert.pem",
    "lib/travis/cli.rb",
    "lib/travis/cli/api_command.rb",
    "lib/travis/cli/command.rb",
    "lib/travis/cli/console.rb",
    "lib/travis/cli/disable.rb",
    "lib/travis/cli/enable.rb",
    "lib/travis/cli/encrypt.rb",
    "lib/travis/cli/endpoint.rb",
    "lib/travis/cli/help.rb",
    "lib/travis/cli/history.rb",
    "lib/travis/cli/login.rb",
    "lib/travis/cli/logs.rb",
    "lib/travis/cli/open.rb",
    "lib/travis/cli/parser.rb",
    "lib/travis/cli/raw.rb",
    "lib/travis/cli/repo_command.rb",
    "lib/travis/cli/restart.rb",
    "lib/travis/cli/show.rb",
    "lib/travis/cli/status.rb",
    "lib/travis/cli/sync.rb",
    "lib/travis/cli/token.rb",
    "lib/travis/cli/version.rb",
    "lib/travis/cli/whatsup.rb",
    "lib/travis/cli/whoami.rb",
    "lib/travis/client.rb",
    "lib/travis/client/artifact.rb",
    "lib/travis/client/build.rb",
    "lib/travis/client/commit.rb",
    "lib/travis/client/entity.rb",
    "lib/travis/client/error.rb",
    "lib/travis/client/job.rb",
    "lib/travis/client/methods.rb",
    "lib/travis/client/namespace.rb",
    "lib/travis/client/repository.rb",
    "lib/travis/client/session.rb",
    "lib/travis/client/states.rb",
    "lib/travis/client/user.rb",
    "lib/travis/pro.rb",
    "lib/travis/tools/formatter.rb",
    "lib/travis/tools/token_finder.rb",
    "lib/travis/version.rb",
    "spec/cli/encrypt_spec.rb",
    "spec/cli/endpoint_spec.rb",
    "spec/cli/help_spec.rb",
    "spec/cli/history_spec.rb",
    "spec/cli/login_spec.rb",
    "spec/cli/logs_spec.rb",
    "spec/cli/open_spec.rb",
    "spec/cli/restart_spec.rb",
    "spec/cli/show_spec.rb",
    "spec/cli/status_spec.rb",
    "spec/cli/token_spec.rb",
    "spec/cli/version_spec.rb",
    "spec/cli/whoami_spec.rb",
    "spec/client/build_spec.rb",
    "spec/client/commit_spec.rb",
    "spec/client/job_spec.rb",
    "spec/client/methods_spec.rb",
    "spec/client/namespace_spec.rb",
    "spec/client/repository_spec.rb",
    "spec/client/session_spec.rb",
    "spec/client/user_spec.rb",
    "spec/client_spec.rb",
    "spec/pro_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/fake_api.rb",
    "spec/support/fake_github.rb",
    "spec/support/helpers.rb",
    "spec/travis_spec.rb",
    "travis.gemspec"
  ]

  # dependencies
  s.add_dependency "faraday",               "~> 0.8"
  s.add_dependency "faraday_middleware",    "~> 0.9"
  s.add_dependency "highline",              "~> 1.6"
  s.add_dependency "netrc",                 "~> 0.7"
  s.add_dependency "gh",                    "~> 0.9"
  s.add_dependency "backports",             "~> 2.6"
  s.add_dependency "launchy",               "~> 2.1"
  s.add_dependency "pry",                   "~> 0.9"
  s.add_development_dependency "rspec",     "~> 2.12"
  s.add_development_dependency "sinatra",   "~> 1.3"
  s.add_development_dependency "rack-test", "~> 0.6"
end
