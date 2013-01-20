# The Travis Client

The [travis gem](https://rubygems.org/gems/travis) includes both a command line client and a Ruby library to interface with a Travis CI service. Both work with [travis-ci.org](https://travis-ci.org), [travis-ci.com](https://travis-ci.com) or any custom Travis CI setup you might have.

## Table of Contents

* [Command Line Client](#command-line-client)
    * [Non-API Commands](#non-api-commands)
        * [`help`](#help)
        * [`version`](#version)
    * [General API Commands](#general-api-commands)
        * [`console`](#console)
        * [`endpoint`](#endpoint)
        * [`login`](#login)
        * [`raw`](#raw)
        * [`whoami`](#whoami)
    * [Repository Commands](#repository-commands)
        * [`encrypt`](#encrypt)
        * [`history`](#history)
        * [`logs`](#logs)
        * [`open`](#open)
        * [`show`](#show)
        * [`status`](#status)
* [Ruby Library](#ruby-library)
    * [Authentication](#authentication)
    * [Using Pro](#using-pro)
    * [Entities](#entities)
        * [Repositories](#repositories)
        * [Builds](#builds)
        * [Jobs](#jobs)
        * [Artifacts](#artifacts)
        * [Users](#users)
        * [Commits](#commits)
    * [Dealing with Sessions](#dealing-with-sessions)
    * [Using Namespaces](#using-namespaces)
* [Installation](#installation)
    * [Upgrading from travis-cli](#upgrading-from-travis-cli)
* [Version History](#version-history)

## Command Line Client

There are three types of commands: [Non-API Commands](#non-api-commands), [General API Commands](#general-api-commands) and [Repository Commands](#repository-commands). All commands take the form of `travis COMMAND [ARGUMENTS] [OPTIONS]`. You can get a list of commands by running [`help`](#help).

### Non-API Commands

Every Travis command takes three global options:

    -h, --help                       Display help
    -i, --[no-]interactive           be interactive and colorful
    -E, --[no-]explode               don't rescue exceptions

The `--help` option is equivalent to running `travis help COMMAND`.

The `--interactive` options determines wether to include additional information and colors in the output or not (except on Windows, we never display colors on Windows, sorry). If you don't set this option explicitly, you will run in interactive mode if you invoke the command directly in a shell and in non-interactive mode if you pipe it somewhere.

You probably want to use `--explode` if you are working on a patch for the Travis client, as it will give you the Ruby exception instead of a nice error message.

#### `help`

The `help` command will inform you about the arguments and options that the commands take, for instance:

    $ travis help help
    Usage: travis help [command] [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions

Running `help` without a command name will give you a list of all available commands.

#### `version`

As you might have guessed, this command prints out the client's version.

### General API Commands

API commands inherit all options from [Non-API Commands](#non-api-commands).

Additionally, every API command understands the following options:

    -e, --api-endpoint URL           Travis API server to talk to
        --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
    -t, --token [ACCESS_TOKEN]       access token to use
        --debug                      show API requests

By default, [General API Commands](#general-api-commands) will talk to [api.travis-ci.org](https://api.travis-ci.org). You can change this by supplying `--pro` for [api.travis-ci.com](https://api.travis-ci.com) or `--api-endpoint` with your own endpoint. Note that all [Repository Commands](#repository-commands) will try to figure out the API endpoint to talk to automatically depending on the project's visibility on GitHub.

You can supply an access token via `--token` if you want to make an authenticated call. If you don't have an access token stored for the API endpoint, it will remember it for subsequent requests. Keep in mind, this is not the "Travis token" used when setting up GitHub hooks (due to security). You probably don't have an access token handy right now. Don't worry, usually you won't use this option but instead just do a [`travis login`](#login).

The `--debug` option will print HTTP requests to STDERR. Like `--explode`, this is really helpful when contributing to this project.

#### `console`

Running `travis console` gives you an interactive Ruby session with all the [entities](#entities) imported into global namespace.

But why use this over just `irb -r travis`? For one, it will take care of authentication, setting the correct endpoint, etc, and it also allows you to pass in `--debug` if you are curious as to what's actually going on.

    $ travis console
    >> User.current
    => #<User: rkh>
    >> Repository.find('sinatra/sinatra')
    => #<Repository: sinatra/sinatra>
    >> _.last_build
    => #<Travis::Client::Build: sinatra/sinatra#360>

#### `endpoint`

Just prints out the API endpoint you're talking to.

    $ travis endpoint
    API endpoint: https://api.travis-ci.org/

Handy for using it when working with shell scripts:

    $ curl "$(travis endpoint)/docs" > docs.html

#### `login`

The `login` command will, well, log you in. That way, all subsequent commands that run against the same endpoint will be authenticated.

    $ travis login
    We need your GitHub login to identify you.
    This information will not be sent to Travis CI, only to GitHub.
    The password will not be displayed.

    Try running with --github-token or --auto if you don't want to enter your password anyways.

    Username: rkh
    Password: *******************

    Successfully logged in!

As you can see above, it will ask you for your GitHub user name and password, but not send these to Travis CI. Instead, it will use them to create a GitHub API token, show the token to Travis, which then on its own checks if you really are who you say you are, and gives you an access token for the Travis API in return. The client will then delete the GitHub token again, just to be sure. But don't worry, all that happens under the hood and fully automatic.

If you don't want it to send your credentials to GitHub, you can create a GitHub token on your own and supply it via `--github-token`. In that case, the client will not delete the GitHub token (as it can't, it needs your password to do this). Travis CI will not store the token, though - after all, it already should have a valid token for you in the database.

A third option is for the really lazy: `--auto`. In this mode the client will try to find a GitHub token for you and just use that. This will only work if you have a [global GitHub token](https://help.github.com/articles/git-over-https-using-oauth-token) stored in your [.netrc](http://blogdown.io/c4d42f87-80dd-45d5-8927-4299cbdf261c/posts/574baa68-f663-4dcf-88b9-9d41310baf2f). If you haven't heard of this, it's worth looking into in general. Again: Travis CI will not store that token.

#### `raw`

This is really helpful both when working on this client and when exploring the [Travis API](https://api.travis-ci.org). It will simply fire a request against the API endpoint, parse the output and pretty print it. Keep in mind that the client takes care of authentication for you:

    $ travis raw /repos/travis-ci/travis
    {"repo"=>
      {"id"=>409371,
       "slug"=>"travis-ci/travis",
       "description"=>"Travis CI Client (CLI and Ruby library)",
       "last_build_id"=>4251410,
       "last_build_number"=>"77",
       "last_build_state"=>"passed",
       "last_build_duration"=>351,
       "last_build_language"=>nil,
       "last_build_started_at"=>"2013-01-19T18:00:49Z",
       "last_build_finished_at"=>"2013-01-19T18:02:17Z"}}

Use `--json` if you'd rather prefer the output to be JSON.

#### `whoami`

This command is useful to verify that you're in fact logged in:

    $ travis whoami
    You are rkh (Konstantin Haase)

Again, like most other commands, goes well with shell scripting:

    $ git clone "https://github.com/$(travis whoami)/some_project"

### Repository Commands

    -h, --help                       Display help
    -i, --[no-]interactive           be interactive and colorful
    -E, --[no-]explode               don't rescue exceptions
    -e, --api-endpoint URL           Travis API server to talk to
        --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
    -t, --token [ACCESS_TOKEN]       access token to use
        --debug                      show API requests
    -r, --repo SLUG

Repository commands have all the options [General API Commands](#general-api-commands) have.

Additionally, you can specify the Repository to talk to by providing `--repo owner/name`. However, if you invoke the command inside a clone of the project, the client will figure out this option on its own. Note that it uses the [git remote](http://www.kernel.org/pub/software/scm/git/docs/git-remote.html) "origin" to do so.

It will also automatically pick [Travis Pro](https://travis-ci.com) if it is a private project. You can of course override this decission with `--pro`, `--org` or `--api-endpoint URL`

#### `encrypt`

    Usage: travis encrypt [args..] [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -r, --repo SLUG
            --add [KEY]                  adds it to .travis.yml under KEY (default: env.global)
        -s, --[no-]split                 treat each line as a separate input

This command is useful to encrypt [environment variables](http://about.travis-ci.org/docs/user/encryption-keys/) or deploy keys for private dependencies.

    $ travis encrypt FOO=bar
    Please add the following to your .travis.yml file:

      secure: "gSly+Kvzd5uSul15CVaEV91ALwsGSU7yJLHSK0vk+oqjmLm0jp05iiKfs08j\n/Wo0DG8l4O9WT0mCEnMoMBwX4GiK4mUmGdKt0R2/2IAea+M44kBoKsiRM7R3\n+62xEl0q9Wzt8Aw3GCDY4XnoCyirO49DpCH6a9JEAfILY/n6qF8="

    Pro Tip™: You can add it automatically by running with --add.

For deploy keys, it is really handy to pipe them into the command:

    $ cat id_rsa | travis encrypt

Another use case for piping files into it: If you have a file with sensitive environment variables, like foreman's [.env](http://ddollar.github.com/foreman/#ENVIRONMENT) file, you can add tell the client to encrypt every line separately via `--split`:

    $ cat .env | travis encrypt --split
    Please add the following to your .travis.yml file:

      secure: "KmMdcwTWGubXVRu93/lY1NtyHxrjHK4TzCfemgwjsYzPcZuPmEA+pz+umQBN\n1ZhzUHZwDNsDd2VnBgYq27ZdcS2cRvtyI/IFuM/xJoRi0jpdTn/KsXR47zeE\nr2bFxRqrdY0fERVHSMkBiBrN/KV5T70js4Y6FydsWaQgXCg+WEU="
      secure: "jAglFtDjncy4E3upL/RF0ZOcmJ2UMrqHFCLQwU8PBdurhTMBeTw+IO6cXx5z\nU5zqvPYo/ghZ8mMuUhvHiGDM6m6OlMP7+l10VTxH1CoVew2NcQvRdfK3P+4S\nZJ43Hyh/ZLCjft+JK0tBwoa3VbH2+ZTzkRZQjdg54bE16C7Mf1A="

    Pro Tip™: You can add it automatically by running with --add.

As suggested, the client can also add them to your `.travis.yml` for you:

    $ travis encrypt FOO=bar --add

This will by default add it as global variables for every job. You can also add it as matrix entries by providing a key:

    $ travis encrypt FOO=bar --add env.matrix

#### `history`

    Usage: travis history [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -r, --repo SLUG
        -a, --after BUILD                Only show history after a given build number
        -p, --pull-request NUMBER        Only show history for the given Pull Request
        -b, --branch BRANCH              Only show history for the given branch
        -l, --limit LIMIT                Maximum number of history items
            --[no-]all                   Display all history items

You can check out what the recent builds look like:

    $ travis history
    #77 passed:   master fix name clash
    #76 failed:   master Merge pull request #11 from travis-ci/rkh-show-logs-history
    #75 passed:   rkh-debug what?
    #74 passed:   rkh-debug all tests pass locally and on the travis vm I spin up :(
    #73 failed:   Pull Request #11 regenerate gemspec
    #72 passed:   rkh-show-logs-history regenerate gemspec
    #71 failed:   Pull Request #11 spec fix for (older) rubinius
    #70 passed:   rkh-show-logs-history spec fix for (older) rubinius
    #69 failed:   Pull Request #11 strange fix for rubinius
    #68 failed:   rkh-show-logs-history strange fix for rubinius

By default, it will display the last 10 builds. You can limit (or extend) the number of builds with `--limit`:

    $ travis history --limit 2
    #77 passed:   master fix name clash
    #76 failed:   master Merge pull request #11 from travis-ci/rkh-show-logs-history

You can use `--after` to display builds after a certain build number (or, well, before, but it's called after to use the same phrases as the API):

    $ travis history --limit 2 --after 76
    #75 passed:   rkh-debug what?
    #74 passed:   rkh-debug all tests pass locally and on the travis vm I spin up :(

You can also limit the history to builds for a certain branch:

    $ travis history --limit 3 --branch master
    #77 passed:   master fix name clash
    #76 failed:   master Merge pull request #11 from travis-ci/rkh-show-logs-history
    #57 passed:   master Merge pull request #5 from travis-ci/hh-multiline-encrypt

Or a certain Pull Request:

    $ travis history --limit 3 --pull-request 5
    #56 passed:   Pull Request #5 Merge branch 'master' into hh-multiline-encrypt
    #49 passed:   Pull Request #5 improve output
    #48 passed:   Pull Request #5 let it generate accessor for line splitting automatically

#### `logs`

Given a job number, logs simply prints out that job's logs.

    $ travis logs 77.1
    [... more logs ...]
    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
    $ bundle exec rake
    /home/travis/.rvm/rubies/ruby-1.8.7-p371/bin/ruby -S rspec spec -c
    Faraday: you may want to install system_timer for reliable timeouts
    ...................................................................................................................................................................

    Finished in 6.48 seconds
    163 examples, 0 failures

    Done. Build script exited with: 0

#### `open`

Opens the project view in the Travis CI web interface. If you pass it a build or job number, it will open that specific view:

    $ travis open

If you just want the URL printed out instead of opened in a browser, pass `--print`.

If instead you want to open the repository, compare or pull request view on GitHub, use `--github`.

    $ travis open 56 --print --github
    web view: https://github.com/travis-ci/travis/pull/5

#### `show`

Displays general infos about the latest build:

    $ travis show
    Build #77: fix name clash
    State:         passed
    Type:          push
    Compare URL:   https://github.com/travis-ci/travis/compare/7cc9b739b0b6...39b66ee24abe
    Duration:      5 min 51 sec
    Started:       2013-01-19 19:00:49
    Finished:      2013-01-19 19:02:17

    #77.1 passed:    45 sec         rvm: 1.8.7
    #77.2 passed:    50 sec         rvm: 1.9.2
    #77.3 passed:    45 sec         rvm: 1.9.3
    #77.4 passed:    46 sec         rvm: 2.0.0
    #77.5 failed:    1 min 18 sec   rvm: jruby (failure allowed)
    #77.6 passed:    1 min 27 sec   rvm: rbx

Any other build:

    $ travis show 1
    Build #1: add .travis.yml
    State:         failed
    Type:          push
    Compare URL:   https://github.com/travis-ci/travis/compare/ad817bc37c76...b8c5d3b463e2
    Duration:      3 min 16 sec
    Started:       2013-01-13 23:15:22
    Finished:      2013-01-13 23:21:38

    #1.1 failed:     21 sec         rvm: 1.8.7
    #1.2 failed:     34 sec         rvm: 1.9.2
    #1.3 failed:     24 sec         rvm: 1.9.3
    #1.4 failed:     52 sec         rvm: 2.0.0
    #1.5 failed:     38 sec         rvm: jruby
    #1.6 failed:     27 sec         rvm: rbx

Or a job:

    $ travis show 77.3
    Job #77.3: fix name clash
    State:         passed
    Type:          push
    Compare URL:   https://github.com/travis-ci/travis/compare/7cc9b739b0b6...39b66ee24abe
    Duration:      45 sec
    Started:       2013-01-19 19:00:49
    Finished:      2013-01-19 19:01:34
    Allow Failure: false
    Config:        rvm: 1.9.3

#### `status`

    Usage: travis status [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -r, --repo SLUG
        -x, --[no-]exit-code             sets the exit code to 1 if the build failed
        -q, --[no-]quiet                 does not print anything
        -p, --[no-]fail-pending          sets the status code to 1 if the build is pending

Outputs a one line status message about the project's last build. With `-q` that line will even not be printed out. How's that useful? Combine it with `-x` and the exit code will be 1 if the build failed, with `-p` and it will be 1 for a pending build.

    $ travis status -qpx && cap deploy

## Ruby Library

... TODO ...

### Authentication

... TODO ...

### Using Pro

... TODO ...

### Entities

#### Repositories

... TODO ...

#### Builds

... TODO ...

#### Jobs

... TODO ...

#### Artifacts

... TODO ...

#### Users

... TODO ...

#### Commits

... TODO ...

### Dealing with Sessions

... TODO ...

### Using Namespaces

... TODO ...

## Installation

Make sure you have at least [Ruby](http://www.ruby-lang.org/en/downloads/) 1.8.7 (1.9.3 recommended) installed. Then run:

    $ gem install travis --no-rdoc --no-ri

### Upgrading from travis-cli

If you have the old `travis-cli` gem installed, you should `gem uninstall travis-cli`, just to be sure, as it ships with an executable that is also named `travis`.

## Version History

**v1.1.0** (not yet released)

* New commands: `console`, `status`, `show`, `logs`, `open` and `history`.
* `--debug` option for all API commands.
* `--split` option for `encrypt`.
* Fix `--add` option for `encrypt` (was naming key `secret` instead of `secure`).
* First class representation for builds, commits and jobs to the Ruby library.
* Print warning when running "encrypt owner/project data", as it's not supported by the new client.
* Improved documentation.

**v1.0.3** (January 15, 2013)

* Fix `-r slug` for repository commands. (#3)

**v1.0.2** (January 14, 2013)

* Only bundle CA certs needed to verify Travis CI and GitHub domains.
* Make tests pass on Windows.

**v1.0.1** (January 14, 2013)

* Improve `encrypt --add` behavior.

**v1.0.0** (January 14, 2013)

* Fist public release.
* Improved documentation.

**v1.0.0pre2**  (January 14, 2013)

* Added Windows support.
* Suggestion to run `travis login` will add `--org` if needed.

**v1.0.0pre** (January 13, 2013)

* Initial public prerelease.