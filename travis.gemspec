# Run `rake travis.gemspec` to update the gemspec.
Gem::Specification.new do |s|
  # general infos
  s.name        = "travis"
  s.version     = "1.5.2"
  s.description = "CLI and Ruby client library for Travis CI"
  s.homepage    = "https://github.com/travis-ci/travis"
  s.summary     = "Travis CI client"
  s.license     = "MIT"
  s.executables = ["travis"]
  s.extensions  = ["completion/extconf.rb"]

  # generated from git shortlog -sn
  s.authors = [
    "Konstantin Haase",
    "Henrik Hodne",
    "Peter Souter",
    "Max Barnash",
    "Aaron Hill",
    "Mathias Meyer",
    "Josh Kalderimis",
    "Justin Lambert",
    "Adrien Brault",
    "Laurent Petit",
    "Daniel Chatfield",
    "Piotr Sarnacki",
    "Rapha\xC3\xABl Pinson",
    "Tobias Wilken",
    "Mario Visic",
    "Benjamin Manns",
    "Jacob Burkhart"
  ]

  # generated from git shortlog -sne
  s.email = [
    "konstantin.mailinglists@googlemail.com",
    "me@henrikhodne.com",
    "p.morsou@gmail.com",
    "i.am@anhero.ru",
    "aa1ronham@gmail.com",
    "meyer@paperplanes.de",
    "jlambert@eml.cc",
    "benmanns@gmail.com",
    "adrien.brault@gmail.com",
    "laurent.petit@gmail.com",
    "chatfielddaniel@gmail.com",
    "drogus@gmail.com",
    "raphael.pinson@camptocamp.com",
    "tw@cloudcontrol.de",
    "mario@mariovisic.com",
    "jburkhart@engineyard.com",
    "josh.kalderimis@gmail.com"
  ]

  # generated from git ls-files
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "bin/travis",
    "completion/extconf.rb",
    "completion/travis.sh",
    "example/org_overview.rb",
    "lib/travis.rb",
    "lib/travis/cacert.pem",
    "lib/travis/cli.rb",
    "lib/travis/cli/accounts.rb",
    "lib/travis/cli/api_command.rb",
    "lib/travis/cli/branches.rb",
    "lib/travis/cli/cancel.rb",
    "lib/travis/cli/command.rb",
    "lib/travis/cli/console.rb",
    "lib/travis/cli/disable.rb",
    "lib/travis/cli/enable.rb",
    "lib/travis/cli/encrypt.rb",
    "lib/travis/cli/endpoint.rb",
    "lib/travis/cli/help.rb",
    "lib/travis/cli/history.rb",
    "lib/travis/cli/init.rb",
    "lib/travis/cli/init/c.yml",
    "lib/travis/cli/init/clojure.yml",
    "lib/travis/cli/init/cpp.yml",
    "lib/travis/cli/init/erlang.yml",
    "lib/travis/cli/init/go.yml",
    "lib/travis/cli/init/groovy.yml",
    "lib/travis/cli/init/haskell.yml",
    "lib/travis/cli/init/java.yml",
    "lib/travis/cli/init/node_js.yml",
    "lib/travis/cli/init/objective-c.yml",
    "lib/travis/cli/init/perl.yml",
    "lib/travis/cli/init/php.yml",
    "lib/travis/cli/init/python.yml",
    "lib/travis/cli/init/ruby.yml",
    "lib/travis/cli/init/scala.yml",
    "lib/travis/cli/login.rb",
    "lib/travis/cli/logs.rb",
    "lib/travis/cli/monitor.rb",
    "lib/travis/cli/open.rb",
    "lib/travis/cli/parser.rb",
    "lib/travis/cli/pubkey.rb",
    "lib/travis/cli/raw.rb",
    "lib/travis/cli/repo_command.rb",
    "lib/travis/cli/restart.rb",
    "lib/travis/cli/setup.rb",
    "lib/travis/cli/show.rb",
    "lib/travis/cli/status.rb",
    "lib/travis/cli/sync.rb",
    "lib/travis/cli/token.rb",
    "lib/travis/cli/version.rb",
    "lib/travis/cli/whatsup.rb",
    "lib/travis/cli/whoami.rb",
    "lib/travis/client.rb",
    "lib/travis/client/account.rb",
    "lib/travis/client/artifact.rb",
    "lib/travis/client/broadcast.rb",
    "lib/travis/client/build.rb",
    "lib/travis/client/commit.rb",
    "lib/travis/client/entity.rb",
    "lib/travis/client/error.rb",
    "lib/travis/client/job.rb",
    "lib/travis/client/listener.rb",
    "lib/travis/client/methods.rb",
    "lib/travis/client/namespace.rb",
    "lib/travis/client/repository.rb",
    "lib/travis/client/restartable.rb",
    "lib/travis/client/session.rb",
    "lib/travis/client/states.rb",
    "lib/travis/client/user.rb",
    "lib/travis/client/worker.rb",
    "lib/travis/pro.rb",
    "lib/travis/tools/formatter.rb",
    "lib/travis/tools/safe_string.rb",
    "lib/travis/tools/token_finder.rb",
    "lib/travis/version.rb",
    "spec/cli/cancel_spec.rb",
    "spec/cli/encrypt_spec.rb",
    "spec/cli/endpoint_spec.rb",
    "spec/cli/help_spec.rb",
    "spec/cli/history_spec.rb",
    "spec/cli/init_spec.rb",
    "spec/cli/login_spec.rb",
    "spec/cli/logs_spec.rb",
    "spec/cli/open_spec.rb",
    "spec/cli/restart_spec.rb",
    "spec/cli/setup_spec.rb",
    "spec/cli/show_spec.rb",
    "spec/cli/status_spec.rb",
    "spec/cli/token_spec.rb",
    "spec/cli/version_spec.rb",
    "spec/cli/whoami_spec.rb",
    "spec/client/account_spec.rb",
    "spec/client/broadcast_spec.rb",
    "spec/client/build_spec.rb",
    "spec/client/commit_spec.rb",
    "spec/client/job_spec.rb",
    "spec/client/methods_spec.rb",
    "spec/client/namespace_spec.rb",
    "spec/client/repository_spec.rb",
    "spec/client/session_spec.rb",
    "spec/client/user_spec.rb",
    "spec/client/worker_spec.rb",
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
  s.add_dependency "faraday",               "~> 0.8.7" # FIXME
  s.add_dependency "faraday_middleware",    "~> 0.9"
  s.add_dependency "highline",              "~> 1.6"
  s.add_dependency "netrc",                 "~> 0.7"
  s.add_dependency "backports"
  s.add_dependency "gh"
  s.add_dependency "launchy",               "~> 2.1"
  s.add_dependency "pry",                   "~> 0.9"
  s.add_dependency "typhoeus",              "~> 0.5"
  s.add_dependency "pusher-client",         "~> 0.3", ">= 0.3.1"
  s.add_dependency "websocket-native",      "~> 1.0"
  s.add_development_dependency "rspec",     "~> 2.12"
  s.add_development_dependency "sinatra",   "~> 1.3"
  s.add_development_dependency "rack-test", "~> 0.6"
end
