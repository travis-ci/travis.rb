# The Travis Client [![Build Status](https://travis-ci.org/travis-ci/travis.png?branch=master)](https://travis-ci.org/travis-ci/travis)

![The Travis Mascot](http://about.travis-ci.org/images/travis-mascot-600px.png)

The [travis gem](https://rubygems.org/gems/travis) includes both a [command line client](#command-line-client) and a [Ruby library](#ruby-library) to interface with a Travis CI service. Both work with [travis-ci.org](https://travis-ci.org), [travis-ci.com](https://travis-ci.com) or any custom Travis CI setup you might have. Check out the [installation instructions](#installation) to get it running in no time.

## Table of Contents

* [Command Line Client](#command-line-client)
    * [Non-API Commands](#non-api-commands)
        * [`help`](#help)
        * [`version`](#version)
    * [General API Commands](#general-api-commands)
        * [`accounts`](#accounts)
        * [`console`](#console)
        * [`endpoint`](#endpoint)
        * [`login`](#login)
        * [`monitor`](#monitor)
        * [`raw`](#raw)
        * [`sync`](#sync)
        * [`token`](#token)
        * [`whatsup`](#whatsup)
        * [`whoami`](#whoami)
    * [Repository Commands](#repository-commands)
        * [`branches`](#branches)
        * [`cancel`](#cancel)
        * [`disable`](#disable)
        * [`enable`](#enable)
        * [`encrypt`](#encrypt)
        * [`history`](#history)
        * [`init`](#init)
        * [`logs`](#logs)
        * [`open`](#open)
        * [`pubkey`](#pubkey)
        * [`restart`](#restart)
        * [`setup`](#setup)
        * [`show`](#show)
        * [`status`](#status)
    * [Environment Variables](#environment-variables)
* [Ruby Library](#ruby-library)
    * [Authentication](#authentication)
    * [Using Pro](#using-pro)
    * [Entities](#entities)
        * [Stateful Entities](#stateful-entities)
        * [Repositories](#repositories)
        * [Builds](#builds)
        * [Jobs](#jobs)
        * [Artifacts](#artifacts)
        * [Users](#users)
        * [Commits](#commits)
        * [Workers](#workers)
    * [Listening for Events](#listening-for-events)
    * [Dealing with Sessions](#dealing-with-sessions)
    * [Using Namespaces](#using-namespaces)
* [Installation](#installation)
    * [Updating your Ruby](#updating-your-ruby)
        * [Mac OSX via Homebrew](#mac-osx-via-homebrew)
        * [Windows](#windows)
        * [Other Unix systems](#other-unix-systems)
        * [Ruby versioning tools](#ruby-versioning-tools)
    * [Upgrading from travis-cli](#upgrading-from-travis-cli)
* [Version History](#version-history)

## Command Line Client

![](http://about.travis-ci.org/images/new-tricks.png)

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
        --adapter ADAPTER            Faraday adapter to use for HTTP requests

By default, [General API Commands](#general-api-commands) will talk to [api.travis-ci.org](https://api.travis-ci.org). You can change this by supplying `--pro` for [api.travis-ci.com](https://api.travis-ci.com) or `--api-endpoint` with your own endpoint. Note that all [Repository Commands](#repository-commands) will try to figure out the API endpoint to talk to automatically depending on the project's visibility on GitHub.

You can supply an access token via `--token` if you want to make an authenticated call. If you don't have an access token stored for the API endpoint, it will remember it for subsequent requests. Keep in mind, this is not the "Travis token" used when setting up GitHub hooks (due to security). You probably don't have an access token handy right now. Don't worry, usually you won't use this option but instead just do a [`travis login`](#login).

The `--debug` option will print HTTP requests to STDERR. Like `--explode`, this is really helpful when contributing to this project.

There are many libraries out there to do HTTP requests in Ruby. You can switch amongst common ones with `--adapter`:

    $ travis show --adapter net-http
    ...
    $ gem install excon
    ...
    $ travis show --adapter excon
    ...

#### `accounts`

The accounts command can be used to list all the accounts you can set up repositories for.

    $ travis accounts
    rkh (Konstantin Haase): subscribed, 160 repositories
    sinatra (Sinatra): subscribed, 9 repositories
    rack (Official Rack repositories): subscribed, 3 repositories
    travis-ci (Travis CI): subscribed, 57 repositories
    ...

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

Prints out the API endpoint you're talking to.

    $ travis endpoint
    API endpoint: https://api.travis-ci.org/

Handy for using it when working with shell scripts:

    $ curl "$(travis endpoint)/docs" > docs.html

It can also be used to set the default API endpoint used for [General API Commands](#general-api-commands):

    $ travis endpoint --pro --set-default
    API endpoint: https://api.travis-ci.com/ (stored as default)

You can use `--drop-default` to remove the setting again:

    $ travis endpoint --drop-default
    default API endpoint dropped (was https://api.travis-ci.com/)

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

#### `monitor`

    Usage: travis monitor [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -m, --my-repos                   Only monitor my own repositories
        -r, --repo SLUG                  monitor given repository (can be used more than once)
        -n, --[no-]notify [TYPE]         send out desktop notifications (optional type: osx, growl, libnotify)

With `monitor` you can watch a live stream of what's going on:

    $ travis monitor
    Monitoring travis-ci.org:
    2013-08-05 01:22:40 questmaster/FATpRemote#45 started
    2013-08-05 01:22:40 questmaster/FATpRemote#45.1 started
    2013-08-05 01:22:41 grangier/python-goose#33.1 passed
    2013-08-05 01:22:42 plataformatec/simple_form#666 passed
    ...

You can limit the repositories to monitor with `--my-repos` and `--repo SLUG`.

The monitor command can also send out desktop notifications (OSX, Growl or libnotify):

    $ travis montior --pro -n
    Monitoring travis-ci.com:
    ...

When monitoring specific repositories, notifications will be turned on by default. Disable with `--no-notify`.

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

### `sync`

    Usage: travis sync [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -c, --check                      only check the sync status
        -b, --background                 will trigger sync but not block until sync is done
        -f, --force                      will force sync, even if one is already running

Sometimes the infos Travis CI has about users and repositories become out of date. If that should happen, you can manually trigger a sync:

    $ travis sync
    synchronizing: ........... done

The command blocks until the synchronization is done. You can avoid that with `--background`:

    $ travis sync --background
    starting synchronization

If you just want to know if your account is being synchronized right now, use `--check`:

    $ travis sync --check
    rkh is currently syncing

#### `token`

In order to use the Ruby library you will need to obtain an access token first. To do this simply run the `travis login` command. Once logged in you can check your token with `travis token`:

    $ travis token
    Your access token is super-secret

You can use that token for instance with curl:

    $ curl -H "Authorization: token $(travis token)" https://api.travis-ci.org/users/
    {"login":"rkh","name":"Konstantin Haase","email":"konstantin.haase@gmail.com","gravatar_id":"5c2b452f6eea4a6d84c105ebd971d2a4","locale":"en","is_syncing":false,"synced_at":"2013-01-21T20:31:06Z"}

Note that if you just need it for looking at API payloads, that we also have the [`raw`](#raw) command.

#### `whatsup`

It's just a tiny feature, but it allows you to take a look at repositories that have recently seen some action (ie the left hand sidebar on [travis-ci.org](https://travis-ci.org)):

    $ travis whatsup
    mysociety/fixmystreet started: #154
    eloquent/typhoon started: #228
    Pajk/apipie-rails started: #84
    qcubed/framework failed: #21
    ...

If you only want to see what happened in your repositories, add the `--my-repos` flag (short: `-m`):

    $ travis whatsup -m
    travis-ci/travis passed: #169
    rkh/dpl passed: #50
    rubinius/rubinius passed: #3235
    sinatra/sinatra errored: #619
    rtomayko/tilt failed: #162
    ruby-no-kai/rubykaigi2013 passed: #50
    rack/rack passed: #519
    ...

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

Additionally, you can specify the Repository to talk to by providing `--repo owner/name`. However, if you invoke the command inside a clone of the project, the client will figure out this option on its own. Note that it uses the tracked [git remote](http://www.kernel.org/pub/software/scm/git/docs/git-remote.html) for the current branch (and defaults to 'origin' if no tracking is set) to do so.

It will also automatically pick [Travis Pro](https://travis-ci.com) if it is a private project. You can of course override this decission with `--pro`, `--org` or `--api-endpoint URL`

#### `branches`

Displays the most recent build for each branch:

    $ travis branches
    hh-add-warning-old-style:                  #35   passed     Add a warning if old-style encrypt is being used
    hh-multiline-encrypt:                      #55   passed     Merge branch 'master' into hh-multiline-encrypt
    rkh-show-logs-history:                     #72   passed     regenerate gemspec
    rkh-debug:                                 #75   passed     what?
    hh-add-clear-cache-to-global-session:      #135  passed     Add clear_cache(!) to Travis::Namespace
    hh-annotations:                            #146  passed     Initial annotation support
    hh-remove-newlines-from-encrypted-string:  #148  errored    Remove all whitespace from an encrypted string
    version-check:                             #157  passed     check travis version for updates from time to time
    master:                                    #163  passed     add Repository#branches and Repository#branch(name)

For more fine grained control and older builds on a specific branch, see [`history`](#history).

#### `cancel`

This command will cancel the latest build:

    $ travis cancel
    build #85 has been canceled

You can also cancel any build by giving a build number:

    $ travis cancel 57
    build #57 has been canceled

Or a single job:

    $ travis cancel 57.1
    job #57.1 has been canceled

#### `disable`

If you want to turn of a repository temporarily or indefinitely, you can do so with the `disable` command:

    $ travis disable
    travis-ci/travis: disabled :(

#### `enable`

With the `enable` command, you can easily activate a project on Travis CI:

    $ travis enable
    travis-ci/travis: enabled :)

It even works when enabling a repo Travis didn't know existed by triggering a sync:

    $ travis enable -r rkh/test
    repository not known to Travis CI (or no access?)
    triggering sync: ............. done
    rkh/test: enabled

If you don't want the sync to be triggered, use `--skip-sync`.

#### `encrypt`

    Usage: travis encrypt [args..] [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -a, --add [KEY]                  adds it to .travis.yml under KEY (default: env.global)
        -s, --[no-]split                 treat each line as a separate input
        -p, --append                     don't override existing values, instead treat as list
        -x, --override                   override existing value

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

There are two ways the client can treat existing values:

* Turn existing value into a list if it isn't already, append new value to that list. This is the default behavior for keys that start with `env.` and can be enforced with `--append`.
* Replace existing value. This is the default behavior for keys that do not start with `env.` and can be enforced with `--override`.

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

#### `init`

    Usage: travis init [language] [file] [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -s, --skip-sync                  don't trigger a sync if the repo is unknown
        -f, --force                      override .travis.yml if it already exists
        -k, --skip-enable                do not enable project, only add .travis.yml
        -p, --print-conf                 print generated config instead of writing to file
            --script VALUE               sets script option in .travis.yml (can be used more than once)
            --before-script VALUE        sets before_script option in .travis.yml (can be used more than once)
            --after-script VALUE         sets after_script option in .travis.yml (can be used more than once)
            --after-success VALUE        sets after_success option in .travis.yml (can be used more than once)
            --install VALUE              sets install option in .travis.yml (can be used more than once)
            --before-install VALUE       sets before_install option in .travis.yml (can be used more than once)
            --compiler VALUE             sets compiler option in .travis.yml (can be used more than once)
            --otp-release VALUE          sets otp_release option in .travis.yml (can be used more than once)
            --go VALUE                   sets go option in .travis.yml (can be used more than once)
            --jdk VALUE                  sets jdk option in .travis.yml (can be used more than once)
            --node-js VALUE              sets node_js option in .travis.yml (can be used more than once)
            --perl VALUE                 sets perl option in .travis.yml (can be used more than once)
            --php VALUE                  sets php option in .travis.yml (can be used more than once)
            --python VALUE               sets python option in .travis.yml (can be used more than once)
            --rvm VALUE                  sets rvm option in .travis.yml (can be used more than once)
            --scala VALUE                sets scala option in .travis.yml (can be used more than once)
            --env VALUE                  sets env option in .travis.yml (can be used more than once)
            --gemfile VALUE              sets gemfile option in .travis.yml (can be used more than once)

When setting up a new project, you can run `travis init` to generate a `.travis.yml` and [enable](#enable) the project:

    $ travis init java
    .travis.yml file created!
    travis-ci/java-example: enabled :)

You can also set certain values via command line flags (see list above):

    $ travis init c --compiler clang
    .travis.yml file created!
    travis-ci/c-example: enabled :)

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

#### `pubkey`

Outputs the public key for a repository.

    $ travis pubkey
    Public key for travis-ci/travis:
    
    ssh-rsa ...
    $ travis pubkey -r rails/rails > rails.key

The `--pem` flag will print out the key PEM encoded:

    $ travis pubkey --pem
    Public key for travis-ci/travis:

    -----BEGIN PUBLIC KEY-----
    ...
    -----END PUBLIC KEY-----

#### `restart`

This command will restart the latest build:

    $ travis restart
    build #85 has been restarted

You can also restart any build by giving a build number:

    $ travis restart 57
    build #57 has been restarted

Or a single job:

    $ travis restart 57.1
    job #57.1 has been restarted

#### `setup`

Helps you configure Travis addons.

    Usage: travis setup service [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -f, --force                      override config section if it already exists

Available services: `cloudcontrol`, `cloudfoundry`, `engineyard`, `heroku`, `nodejitsu`, `npm`, `openshift`, `pypi`, `rubygems` and `sauce_connect`.

Example:

    $ travis setup heroku
    Deploy only from travis-ci/travis-chat? |yes|
    Encrypt API key? |yes|

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

The last build for a given branch:

    $ travis show rkh-debug
    Build #75: what?
    State:         passed
    Type:          push
    Branch:        rkh-debug
    Compare URL:   https://github.com/travis-ci/travis/compare/8d4aa5254359...7ef33d5e5993
    Duration:      6 min 16 sec
    Started:       2013-01-19 18:51:17
    Finished:      2013-01-19 18:52:43

    #75.1 passed:    1 min 10 sec   rvm: 1.8.7
    #75.2 passed:    51 sec         rvm: 1.9.2
    #75.3 passed:    36 sec         rvm: 1.9.3
    #75.4 passed:    48 sec         rvm: 2.0.0
    #75.5 failed:    1 min 26 sec   rvm: jruby (failure allowed)
    #75.6 passed:    1 min 25 sec   rvm: rbx

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

### Environment Variables

You can set the following environment variables to influence the travis behavior:

* `$TRAVIS_TOKEN` - access token to use when the `--token` flag is not user
* `$TRAVIS_ENDPOINT` - API endpoint to use when the `--api-endpoint`, `--org` or `--pro` flag is not used
* `$TRAVIS_CONFIG_PATH` - directory to store configuration in (defaults to ~/.travis)

## Ruby Library

There are two approaches of using the Ruby library, one straight forward with one global session:

``` ruby
require 'travis'

rails = Travis::Repository.find('rails/rails')
puts "oh no" unless rails.green?
```

And one where you have to instantiate your own session:

``` ruby
require 'travis/client'

client = Travis::Client.new
rails  = client.repo('rails/rails')
puts "oh no" unless rails.green?
```

For most parts, those are pretty much the same, the entities you get back look the same, etc, except one offers nice constants as part of the API, the other doesn't. In fact the "global" session style uses `Travis::Client` internally.

So, which one to choose? The global style has one session, whereas with the client style, you have one session per client instance. Each session has it's own cache and identity map. This might matter for log running processes. If you use a new session for separate units of work, you can be pretty sure to not leak any objects. On the other hand using the constants or reusing the same session might save you from unnecessary HTTP requests.

In either way, if you should use the first approach or long living clients, here is how you make sure not to have stale data around:

``` ruby
Travis.clear_cache
client.clear_cache
```

Note that this will still keep the identity map around, it will only drop all attributes. To clear the identity map, you can use the `clear_cache!` method. However, if you do that, you should not keep old instances of any entities (like repositories, etc) around.

### Authentication

Authentication is pretty easy, you just need to set an access token:

``` ruby
require 'travis'

Travis.access_token = "..."
puts "Hello #{Travis::User.current.name}!"
```

Or with your own client instance:

``` ruby
require 'travis/client'

client = Travis::Client.new(access_token: "...")
puts "Hello #{client.user.name}"
```

See [the token command](#token) for obtaining the access token used by the CLI.

If you don't have an access token for Travis CI, you can use a GitHub access token to get one:

``` ruby
require 'travis'

Travis.github_auth("...")
puts "Hello #{Travis::User.current.name}!"
```

Travis CI will not store that token.

### Using Pro

Using the library with private projects pretty much works the same, except you use `Travis::Pro`.

Keep in mind that you need to authenticate.

``` ruby
require 'travis/pro'

Travis::Pro.access_token = '...'
user = Travis::Pro::User.current

puts "Hello #{user.name}!"
```

### Entities

Entities are like the models in the Travis Client land. They keep the data and it's usually them you talk to if you want something.
They are pretty much normal Ruby objects.

The Travis session will cache all entities, so don't worry about loading the same one twice.
Once you got a hold of one, you can easily reload it at any time if you want to make sure the data is fresh:

``` ruby
rails = Travis::Repository.find('rails/rails')
sleep 1.hour
rails.reload
```

The travis gem supports lazy and partial loading, so if you want to make sure you have all the data, just call load.

``` ruby
rails.load
```

This is not something you should usually do, as partial loading is actually your friend (keeps requests to a minimum).


#### Stateful Entities

[Repositories](#repositories), [Builds](#builds) and [Jobs](#jobs) all are basically state machines, which means the implement the following methods:

``` ruby
require 'travis'
build = Travis::Repository.find('rails/rails').last_build

p build.canceled?
p build.created?
p build.errored?
p build.failed?
p build.finished?
p build.green?
p build.passed?
p build.pending?
p build.queued?
p build.red?
p build.running?
p build.started?
p build.successful?
p build.unsuccessful?
p build.yellow?
p build.color
```

Builds and jobs also have a `state` method. For repositories, use `last_build.state`.

#### Repositories

Repositories are probably one of the first entities you'll load. It's pretty straight forward, too.

``` ruby
require 'travis'

Travis::Repository.find('rails/rails')            # find by slug
Travis::Repository.find(891)                      # find by id
Travis::Repository.find_all(owner_name: 'rails')  # all repos in the rails organization
Travis::Repository.current                        # repos that see some action right now

# all repos with the same owner as the repo with id 891
Travis::Repository.find(891).owner.repositories
```

Once you have a repository, you can for instance encrypt some strings with its private key:

``` ruby
require 'travis'

Travis::Repository.find('rails/rails')
puts repo.encrypt('FOO=bar')
```

Repositories are [stateful](#stateful-entities).

You can enable or disable a repository with the methods that go by the same name.

``` ruby
rails.disable
system "push all the things"
rails.enable
```

If you want to enable a new project, you might have to do a sync first.

#### Builds

You could load a build by its id using `Travis::Build.find`. But most of the time you won't have the id handy, so you'd usually start with a repository.

``` ruby
require 'travis'
rails = Travis::Repository.find('rails/rails')

rails.last_build               # the latest build
rails.recent_builds            # the last 20 or so builds (don't rely on that number)
rails.builds(after_number: 42) # the last 20 or so builds *before* 42
rails.build(42)                # build with the number 42 (not the id!)
rails.builds                   # Enumerator for #each_build

# this will loop through all builds
rails.each_build do |build|
  puts "#{build.number}: #{build.state}"
end

# this will loop through all builds before build 42
rails.each_build(after_number: 42) do |build|
  puts "#{build.number}: #{build.state}"
end
```

Note that `each_build` (and thus `builds` without and argument) is lazy and uses pagination, so you can safely do things like this:

``` ruby
build = rails.builds.detect { |b| b.failed? }
puts "Last failing Rails build: #{build.number}"
```

Without having to load more than 6000 builds.

You can restart a build, if the current user has sufficient permissions on the repository:

``` ruby
rails.last_build.restart
```

Same goes for canceling it:

``` ruby
rails.last_build.cancel
```

You can also retrieve a Hash mapping branch names to the latest build on that given branch via `branches` or use the `branch` method to get the last build for a specific branch:

``` ruby
if rails.branch('4-0-stable').green?
  puts "Time for another 4.0.x release!"
end

count = rails.branches.size
puts "#{count} rails branches tested on travis"
```

#### Jobs

Jobs behave a lot like [builds](#builds), and similar to them, you probably don't have the id ready. You can get the jobs from a build:

``` ruby
rails.last_build.jobs.each do |job|
  puts "#{job.number} took #{job.duration} seconds"
end
```

If you have the job number, you can also reach a job directly from the repository:

``` ruby
rails.job('5000.1')
```

Like builds, you can also restart singe jobs:

``` ruby
rails.job('5000.1').restart
```

Same goes for canceling it:

``` ruby
rails.job('5000.1').cancel
```

#### Artifacts

The artifacts you usually care for are probably logs. You can reach them directly from a build:

``` ruby
require 'travis'

repo = Travis::Repository.find('travis-ci/travis')
job  = repo.last_build.jobs.first
puts job.log.body
```

If you plan to print our the body, be aware that it might contain malicious escape codes. For this reason, we added `colorized_body`, which removes all the unprintable characters, except for ANSI color codes, and `clean_body` which also removes the color codes.

``` ruby
puts job.log.colorized_body
````

You can stream a body for a job that is currently running by passing a block:

``` ruby
job.log.body { |chunk| print chunk }
```

#### Users

The only user you usually get access to is the currently authenticated one.

``` ruby
require 'travis'

Travis.access_token = '...'
user = Travis::User.current

puts "Hello, #{user.login}! Or should I call you... #{user.name.upcase}!?"
```

If some data gets out of sync between GitHub and Travis, you can use the user object to trigger a new sync.

``` ruby
Travis::User.current.sync
```

#### Commits

Commits cannot be loaded directly. They come as a byproduct of [jobs](#jobs) and [builds](#builds).

``` ruby
require 'travis'

repo   = Travis::Repository.find('travis-ci/travis')
commit = repo.last_build.commit

puts "Last tested commit: #{commit.short_sha} on #{commit.branch} by #{commit.author_name} - #{commit.subject}"
```

#### Workers

If a worker is running something, it will reference a `job` and a `repository`. Otherwise the values will be `nil`.

``` ruby
require 'travis'
workers = Travis::Worker.find_all

workers.each do |worker|
  puts "#{worker.name}: #{worker.host} - #{worker.state} - #{worker.repository.slug if worker.repository}"
end
```

### Dealing with Sessions

Under the hood the session is where the fun is happening. Most methods on the constants and entities just wrap methods on your session, so you don't have to pass the session around all the time or even see it if you don't want to.

There are two levels of session methods, the higher level methods from the `Travis::Client::Methods` mixin, which are also available from `Travis`, `Travis::Pro` or any custom [Namespace](#using-namespaces).

``` ruby
require 'travis/client/session'
session = Travis::Client::Session.new

session.access_token = "secret_token"           # access token to use
session.api_endpoint = "http://localhost:3000/" # api endpoint to talk to
session.github_auth("github_token")             # log in with a github token
session.repos(owner_name: 'travis-ci')          # all travis-ci/* projects
session.repo('travis-ci/travis')                # this project
session.repo(409371)                            # same as the one above
session.build(4266036)                          # build with id 4266036
session.job(4266037)                            # job with id 4266037
session.artifact(42)                            # artifact with id 42
session.log(42)                                 # same as above
session.user                                    # the current user, if logged in
session.restart(session.build(4266036))         # restart some build
session.cancel(session.build(4266036))          # cancel some build
```

You can add these methods to any object responding to `session` via said mixin.

Below this, there is a second API, close to the HTTP level:

``` ruby
require 'travis/client/session'
session = Travis::Client::Session.new

session.instrument do |description, block|
  time = Time.now
  block.call
  puts "#{description} took #{Time.now - time} seconds"
end

session.connection = Faraday::Connection.new

session.get_raw('/repos/rails/rails') # => {"repo" => {"id" => 891, "slug" => "rails/rails", ...}}
session.get('/repos/rails/rails')     # => {"repo" => #<Travis::Client::Repository: rails/rails>}
session.headers['Foo'] = 'Bar'        # send a custom HTTP header with every request

rails = session.find_one(Travis::Client::Repository, 'rails/rails')

session.find_many(Travis::Client::Repository)  # repositories with the latest builds
session.find_one_or_many(Travis::Client::User) # the current user (you could also use find_one here)

session.reload(rails)
session.reset(rails)  # lazy reload

session.clear_cache   # empty cached attributes
session.clear_cache!  # empty identity map
```

### Listening for Events

You can use the `listen` method to listen for events on repositories, builds or jobs:

``` ruby
require 'travis'

rails   = Travis::Repository.find("rails/rails")
sinatra = Travis::Repository.find("sinatra/sinatra")

Travis.listen(rails, sinatra) do |stream|
  stream.on('build:started', 'build:finished') do |event|
    # ie "rails/rails just passed"
    puts "#{event.repository.slug} just #{event.build.state}"
  end
end
```

Current events are `build:created`, `build:started`, `build:finished`, `job:created`, `job:started`, `job:finished` and `job:log` (the last one only when subscribing to jobs explicitly). Not passing any arguments to `listen` will monitor the global stream.

### Using Namespaces

`Travis` and `Travis::Pro` are just two different namespaces for two different Travis sessions. A namespace is a Module, exposing the higher level [session methods](#dealing-with-sessions). It also has a dummy constant for every [entity](#entities), wrapping `find_one` (aliased to `find`) and `find_many` (aliased to `find_all`) for you, so you don't have to keep track of the session or hand in the entity class. You can easily create your own namespace:

``` ruby
require 'travis/client'
MyTravis = Travis::Client::Namespaces.new("http://localhost:3000")

MyTravis.access_token = "..."
MyTravis::Repository.find("foo/bar")
```

Since namespaces are Modules, you can also include them.

``` ruby
require 'travis/client'

class MyTravis
  include Travis::Client::Namespaces.new
end

MyTravis::Repository.find('rails/rails')
```

## Installation

Make sure you have at least [Ruby](http://www.ruby-lang.org/en/downloads/) 1.9.3 (2.0.0 recommended) installed.

You can check your Ruby version by running `ruby -v`:

    $ ruby -v
    ruby 2.0.0p195 (2013-05-14 revision 40734) [x86_64-darwin12.3.0]

Then run:

    $ gem install travis -v 1.5.5 --no-rdoc --no-ri

Now make sure everything is working:

    $ travis version
    1.5.5

### Development Version

You can also install the development version via RubyGems:

    $ gem install --pre

We automatically publish a new development version after every successful build.

### Updating your Ruby

If you have an outdated Ruby version, you should use your package system or a Ruby Installer to install a recent Ruby.

#### Mac OSX via Homebrew

Mac OSX prior to 10.9 ships with a very dated Ruby version. You can use [Homebrew](http://mxcl.github.io/homebrew/) to install a recent version:

    $ brew install ruby
    $ gem update --system

#### Windows

On Windows, we recommend using the [RubyInstaller](http://rubyinstaller.org/), which includes the latest version of Ruby.

#### Other Unix systems

On other Unix systems, like Linux, use your package system to install Ruby. Please inquire before hand which package you might actually want to install, as for some distributions `ruby` might actually still be 1.8.7 or older.

Ubuntu and Debian:

    $ sudo apt-get install ruby1.9.3 ruby-switch
    $ sudo ruby-switch --set ruby1.9.3

Fedora Core:

    $ sudo yum install ruby

Arch Linux:

    $ sudo pacman -S ruby


#### Ruby versioning tools

Alternatively, you can use a Ruby version management tool such as [rvm](https://rvm.io/rvm/install/), [rbenv](http://rbenv.org/) or [https://github.com/postmodern/chruby](chruby). This is only recommended if you need to run multiple versions of Ruby.

You can of course always compile Ruby from source, though then you are left with the hassle of keeping it up to date and making sure that everything is set up properly.

### Upgrading from travis-cli

If you have the old `travis-cli` gem installed, you should `gem uninstall travis-cli`, just to be sure, as it ships with an executable that is also named `travis`.

## Version History

**unreleased changes**

* Use new API for fetching a single branch for Repository#branch. This also circumvents the 25 branches limit.
* Start publishing gem prereleases after successful builds.
* Add `account` method for fetching a single account to `Travis::Client::Methods`.
* Allow creating account objects for any account, not just these the user is part of. Add `Account#member?` to check for membership.
* Add `Account#repositories` to load all repos for a given account.
* Add `Repository#owner_name` and `Repository#owner` to load the account owning a repository.
* Add `Repository#member?` to check if the current user is a member of a repository.
* Add `Build#pull_request_number` and `Build#pull_request_title`.

**1.5.5** (October 2, 2013)

* Add `travis setup pypi`
* Add `travis setup npm`
* When loading accounts, set all flag to true.
* Fix bug where session.config would be nil instead of a hash.

**1.5.4** (September 7, 2013)

* Make `travis monitor` send out desktop notifications.
* List available templates on `travis init --help`.
* List available services on `travis setup --help`.
* Make `travis setup cloudfoundry` detect the target automatically if possible
* Have `travis setup` ask if you want to deploy/release from current branch if not on master.
* Give autocompletion on zsh [superpowers](http://ascii.io/a/5139).
* Add `Repository#github_language`.
* `travis init` now is smarter when it comes to detecting the template to use (ie, "CoffeeScript" will be mapped to "node_js")
* Running `travis init` without a language will now use `Repository#github_language` as default language rather than ruby.
* Make `travis login` and `travis login --auto` work with GitHub Enterprise.
* Make `travis login` work with two factor authentication.
* Add `travis endpoint --github`.
* Make `travis accounts` handle accounts without name better.

**1.5.3** (August 22, 2013)

* Fix issues on Windows.
* Improve `travis setup rubygems` (automatically figure out API token for newer RubyGems versions, offer to only release tagged commits, allow changing gem name).
* Add command descriptions to help pages.
* Smarter check if travis gem is outdated.
* Better error messages for non-existing build/job numbers.

**1.5.2** (August 18, 2013)

* Add `travis cancel`.
* Add `Build#cancel` and `Job#cancel` to Ruby API.
* Add `travis setup cloudfoundry`.
* Add `--set-default` and `--drop-default` to `travis endpoint`.
* Make it possible to configure cli via env variables (`$TRAVIS_TOKEN`, `$TRAVIS_ENDPOINT` and `$TRAVIS_CONFIG_PATH`).
* Improve `travis setup cloudcontrol`.

**1.5.1** (August 15, 2013)

* Add `travis setup engineyard`.
* Add `travis setup cloudcontrol`.
* Silence warnings when running `travis help` or `travis console`.

**1.5.0** (August 7, 2013)

* Add `travis setup rubygems`.
* Add `travis accounts`.
* Add `travis monitor`.
* Make `travis logs` stream.
* Add Broadcast entity.
* Add streaming body API.
* Add event listener API.
* Add simple plugin system (will load any ~/.travis/*/init.rb when running cli).
* Implement shell completion for bash and zsh.
* Be smarter about warnings when running `travis encrypt`.
* Improve documentation.

**1.4.0** (July 26, 2013)

* Add `travis init`
* Improve install documentation, especially for people from outside the Ruby community
* Improve error message on an expired token
* Add Account entity to library
* Switch to Typhoeus as default HTTP adapter
* Fix tests for forks

**1.3.1** (July 21, 2013)

* Add `travis whatsup --my-repos`, which corresponds to the "My Repositories" tab in the web interface
* It is now recommended to use Ruby 2.0, any Ruby version prior to 1.9.3 will lead to a warning being displayed. Disable with `--skip-version-check`.
* Add `--override` and `--append` to `travis encrypt`, make default behavior depend on key.
* Add shorthand for `travis encrypt --add`.

**1.3.0** (July 20, 2013)

* Add `travis setup [heroku|openshift|nodejitsu|sauce_connect]`
* Add `travis branches`
* Add Repository#branch and Repository#branches
* Improve `--help`
* Improve error message when calling `travis logs` with a matrix build number
* Check if travis gem is up to date from time to time (CLI only, not when used as library)

**1.2.8** (July 19, 2013)

* Make pubkey print out key in ssh encoding, add --pem flag for old format
* Fix more encoding issues
* Fix edge cases that broke history view

**1.2.7** (July 15, 2013)

* Add pubkey command
* Remove all whitespace from an encrypted string

**v1.2.6** (July 7, 2013)

* Improve output of history command

**v1.2.5** (July 7, 2013)

* Fix encoding issue

**v1.2.4** (July 7, 2013)

* Allow empty commit message

**v1.2.3** (June 27, 2013)

* Fix encoding issue
* Will detect github repo from other remotes besides origin
* Add clear_cache(!) to Travis::Namespace

**v1.2.2** (May 24, 2013)

* Fixed `travis disable`.
* Fix edge cases around `travis encrypt`.

**v1.2.1** (May 24, 2013)

* Builds with high build numbers are properly aligned when running `travis history`.
* Don't lock against a specific backports version, makes it easier to use it as a Ruby library.
* Fix encoding issues.

**v1.2.0** (February 22, 2013)

* add `--adapter` to API endpoints
* added branch to `show`
* fix bug where colors were not used if stdin is a pipe
* make `encrypt` options `--split` and `--add` work together properly
* better handling of missing or empty `.travis.yml` when running `encrypt --add`
* fix broken example code
* no longer require network connection to automatically detect repository slug
* add worker support to the ruby library
* adjust artifacts/logs code to upstream api changes

**v1.1.3** (January 26, 2013)

* use persistent HTTP connections (performance for commands with multiple api requests)
* include round trip time in debug output

**v1.1.2** (January 24, 2013)

* `token` command
* no longer wrap $stdin in delegator (caused bug on some Linux systems)
* correctly detect when running on Windows, even on JRuby

**v1.1.1** (January 22, 2013)

* Make pry a runtime dependency rather than a development dependency.

**v1.1.0** (January 21, 2013)

* New commands: `console`, `status`, `show`, `logs`, `history`, `restart`, `sync`, `enable`, `disable`, `open` and `whatsup`.
* `--debug` option for all API commands.
* `--split` option for `encrypt`.
* Fix `--add` option for `encrypt` (was naming key `secret` instead of `secure`).
* First class representation for builds, commits and jobs in the Ruby library.
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
