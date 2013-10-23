# Run `rake travis.gemspec` to update the gemspec.
Gem::Specification.new do |s|
  # general infos
  s.name        = "travis"
  s.version     = "1.5.6"
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
    "Aaron Hill",
    "Peter Souter",
    "Peter van Dijk",
    "Max Barnash",
    "Mathias Meyer",
    "Josh Kalderimis",
    "Justin Lambert",
    "Adrien Brault",
    "Laurent Petit",
    "Maarten van Vliet",
    "Mario Visic",
    "Neamar",
    "Piotr Sarnacki",
    "Rapha\xC3\xABl Pinson",
    "Tobias Wilken",
    "Daniel Chatfield",
    "Adam Lavin",
    "Benjamin Manns",
    "Jacob Burkhart"
  ]

  # generated from git shortlog -sne
  s.email = [
    "konstantin.mailinglists@googlemail.com",
    "aa1ronham@gmail.com",
    "me@henrikhodne.com",
    "p.morsou@gmail.com",
    "henrik@hodne.io",
    "peter.van.dijk@netherlabs.nl",
    "i.am@anhero.ru",
    "meyer@paperplanes.de",
    "adam@lavoaster.co.uk",
    "laurent.petit@gmail.com",
    "benmanns@gmail.com",
    "mario@mariovisic.com",
    "neamar@neamar.fr",
    "drogus@gmail.com",
    "raphael.pinson@camptocamp.com",
    "tw@cloudcontrol.de",
    "maartenvanvliet@gmail.com",
    "chatfielddaniel@gmail.com",
    "jburkhart@engineyard.com",
    "josh.kalderimis@gmail.com",
    "jlambert@eml.cc",
    "adrien.brault@gmail.com"
  ]

  # generated from git ls-files
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "assets/cacert.pem",
    "assets/init/c.yml",
    "assets/init/clojure.yml",
    "assets/init/cpp.yml",
    "assets/init/erlang.yml",
    "assets/init/go.yml",
    "assets/init/groovy.yml",
    "assets/init/haskell.yml",
    "assets/init/java.yml",
    "assets/init/node_js.yml",
    "assets/init/objective-c.yml",
    "assets/init/perl.yml",
    "assets/init/php.yml",
    "assets/init/python.yml",
    "assets/init/ruby.yml",
    "assets/init/scala.yml",
    "assets/notifications/Travis CI.app/Contents/Info.plist",
    "assets/notifications/Travis CI.app/Contents/MacOS/Travis CI",
    "assets/notifications/Travis CI.app/Contents/PkgInfo",
    "assets/notifications/Travis CI.app/Contents/Resources/Travis CI.icns",
    "assets/notifications/Travis CI.app/Contents/Resources/en.lproj/Credits.rtf",
    "assets/notifications/Travis CI.app/Contents/Resources/en.lproj/InfoPlist.strings",
    "assets/notifications/Travis CI.app/Contents/Resources/en.lproj/MainMenu.nib",
    "assets/notifications/icon.png",
    "assets/travis.sh",
    "assets/travis.sh.erb",
    "bin/travis",
    "example/org_overview.rb",
    "lib/travis.rb",
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
    "lib/travis/cli/login.rb",
    "lib/travis/cli/logout.rb",
    "lib/travis/cli/logs.rb",
    "lib/travis/cli/monitor.rb",
    "lib/travis/cli/open.rb",
    "lib/travis/cli/parser.rb",
    "lib/travis/cli/pubkey.rb",
    "lib/travis/cli/raw.rb",
    "lib/travis/cli/repo_command.rb",
    "lib/travis/cli/restart.rb",
    "lib/travis/cli/setup.rb",
    "lib/travis/cli/setup/appfog.rb",
    "lib/travis/cli/setup/cloud_control.rb",
    "lib/travis/cli/setup/cloud_foundry.rb",
    "lib/travis/cli/setup/engine_yard.rb",
    "lib/travis/cli/setup/heroku.rb",
    "lib/travis/cli/setup/nodejitsu.rb",
    "lib/travis/cli/setup/npm.rb",
    "lib/travis/cli/setup/open_shift.rb",
    "lib/travis/cli/setup/pypi.rb",
    "lib/travis/cli/setup/ruby_gems.rb",
    "lib/travis/cli/setup/s3.rb",
    "lib/travis/cli/setup/sauce_connect.rb",
    "lib/travis/cli/setup/service.rb",
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
    "lib/travis/tools/assets.rb",
    "lib/travis/tools/completion.rb",
    "lib/travis/tools/formatter.rb",
    "lib/travis/tools/notification.rb",
    "lib/travis/tools/safe_string.rb",
    "lib/travis/tools/system.rb",
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
  s.add_dependency "gh",                    "~> 0.13"
  s.add_dependency "launchy",               "~> 2.1"
  s.add_dependency "pry",                   "~> 0.9"
  s.add_dependency "typhoeus",              "~> 0.6"
  s.add_dependency "pusher-client",         "~> 0.4"
  s.add_dependency "addressable",           "~> 2.3"
  s.add_development_dependency "rspec",     "~> 2.12"
  s.add_development_dependency "sinatra",   "~> 1.3"
  s.add_development_dependency "rack-test", "~> 0.6"

  # Prereleasing on Travis CI
  s.version = s.version.to_s.succ + ".travis.#{ENV['TRAVIS_JOB_NUMBER']}" if ENV['CI']
end
