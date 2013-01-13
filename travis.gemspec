# Run `rake travis.gemspec` to update the gemspec.
Gem::Specification.new do |s|
  # general infos
  s.name        = "travis"
  s.version     = "1.0.0"
  s.description = "CLI and Ruby client library for Travis CI"
  s.homepage    = "https://github.com/travis-ci/travis"
  s.summary     = "Travis CI client"
  s.license     = "MIT"
  s.executables = ["travis"]

  # generated from git shortlog -sn
  s.authors = [
    "Konstantin Haase"
  ]

  # generated from git shortlog -sne
  s.email = [
    "konstantin.mailinglists@googlemail.com"
  ]

  # generated from git ls-files
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "bin/travis",
    "lib/travis.rb",
    "lib/travis/cli.rb",
    "lib/travis/cli/api_command.rb",
    "lib/travis/cli/command.rb",
    "lib/travis/cli/endpoint.rb",
    "lib/travis/cli/help.rb",
    "lib/travis/cli/login.rb",
    "lib/travis/cli/parser.rb",
    "lib/travis/cli/raw.rb",
    "lib/travis/cli/repo_command.rb",
    "lib/travis/cli/version.rb",
    "lib/travis/cli/whoami.rb",
    "lib/travis/client.rb",
    "lib/travis/client/entity.rb",
    "lib/travis/client/error.rb",
    "lib/travis/client/methods.rb",
    "lib/travis/client/namespace.rb",
    "lib/travis/client/repository.rb",
    "lib/travis/client/session.rb",
    "lib/travis/client/user.rb",
    "lib/travis/pro.rb",
    "lib/travis/tools/token_finder.rb",
    "lib/travis/version.rb",
    "spec/cli/endpoint_spec.rb",
    "spec/cli/help_spec.rb",
    "spec/cli/login_spec.rb",
    "spec/cli/version_spec.rb",
    "spec/cli/whoami_spec.rb",
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
  s.add_development_dependency "rspec",     "~> 2.12"
  s.add_development_dependency "sinatra",   "~> 1.3"
  s.add_development_dependency "rack-test", "~> 0.6"
end
