# The Travis Client [![Build Status](https://travis-ci.com/travis-ci/travis.rb.svg?branch=master)](https://travis-ci.com/travis-ci/travis.rb)

![The Travis Mascot](http://about.travis-ci.org/images/travis-mascot-200px.png)

The [travis gem](https://rubygems.org/gems/travis) includes both a [command line client](#command-line-client) and a [Ruby library](#ruby-library) to interface with a Travis CI service. Both work with [travis-ci.org](https://travis-ci.org), [travis-ci.com](https://travis-ci.com) or any custom Travis CI setup you might have. Check out the [installation instructions](#installation) to get it running in no time.

## Table of Contents

* [Command Line Client](#command-line-client)
    * [Non-API Commands](#non-api-commands)
        * [`help`](#help) - helps you out when in dire need of information
        * [`version`](#version) - outputs the client version
    * [General API Commands](#general-api-commands)
        * [`accounts`](#accounts) - displays accounts and their subscription status
        * [`console`](#console) - interactive shell; requires `pry`
        * [`endpoint`](#endpoint) - displays or changes the API endpoint
        * [`login`](#login) - authenticates against the API and stores the token
        * [`monitor`](#monitor) - live monitor for what's going on
        * [`raw`](#raw) - makes an (authenticated) API call and prints out the result
        * [`report`](#report) - generates a report useful for filing issues
        * [`repos`](#repos) - lists repositories the user has certain permissions on
        * [`sync`](#sync) - triggers a new sync with GitHub
        * [`lint`](#lint) - display warnings for a .travis.yml
        * [`token`](#token) - outputs the secret API token
        * [`whatsup`](#whatsup) - lists most recent builds
        * [`whoami`](#whoami) - outputs the current user
    * [Repository Commands](#repository-commands)
        * [`branches`](#branches) - displays the most recent build for each branch
        * [`cache`](#cache) - lists or deletes repository caches
        * [`cancel`](#cancel) - cancels a job or build
        * [`disable`](#disable) - disables a project
        * [`enable`](#enable) - enables a project
        * [`encrypt`](#encrypt) - encrypts values for the .travis.yml
        * [`encrypt-file`](#encrypt-file) - encrypts a file and adds decryption steps to .travis.yml
        * [`env`](#env) - show or modify build environment variables
        * [`history`](#history) - displays a project's build history
        * [`init`](#init) - generates a .travis.yml and enables the project
        * [`logs`](#logs) - streams test logs
        * [`open`](#open) - opens a build or job in the browser
        * [`pubkey`](#pubkey) - prints out a repository's public key
        * [`requests`](#requests) - lists recent requests
        * [`restart`](#restart) - restarts a build or job
        * [`settings`](#settings) - access repository settings
        * [`setup`](#setup) - sets up an addon or deploy target
        * [`show`](#show) - displays a build or job
        * [`sshkey`](#sshkey) - checks, updates or deletes an SSH key
        * [`status`](#status) - checks status of the latest build
    * [Travis CI and Travis CI Enterprise](#travis-ci-and-travis-ci-enterprise)
    * [Environment Variables](#environment-variables)
    * [Desktop Notifications](#desktop-notifications)
    * [Plugins](#plugins)
        * [Official Plugins](#official-plugins)
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
        * [Caches](#caches)
        * [Repository Settings](#repository-settings)
        * [Build Environment Variables](#build-environment-variables)
    * [Listening for Events](#listening-for-events)
    * [Dealing with Sessions](#dealing-with-sessions)
    * [Using Namespaces](#using-namespaces)
* [Installation](#installation)
    * [Updating your Ruby](#updating-your-ruby)
        * [Mac OS X via Homebrew](#mac-os-x-via-homebrew)
        * [Windows](#windows)
        * [Other Unix systems](#other-unix-systems)
        * [Ruby versioning tools](#ruby-versioning-tools)
    * [Troubleshooting](#troubleshooting)
        * [Ubuntu](#ubuntu)
        * [Mac OS X](#mac-os-x)
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

The `--interactive` options determines whether to include additional information and colors in the output or not (except on Windows, we never display colors on Windows, sorry). If you don't set this option explicitly, you will run in interactive mode if you invoke the command directly in a shell and in non-interactive mode if you pipe it somewhere.

You probably want to use `--explode` if you are working on a patch for the Travis client, as it will give you the Ruby exception instead of a nice error message.

#### `help`

The `help` command will inform you about the arguments and options that the commands take, for instance:

``` console
$ travis help help
Usage: travis help [command] [options]
    -h, --help                       Display help
    -i, --[no-]interactive           be interactive and colorful
    -E, --[no-]explode               don't rescue exceptions
```

Running `help` without a command name will give you a list of all available commands.

#### `version`

As you might have guessed, this command prints out the client's version.

### General API Commands

API commands inherit all options from [Non-API Commands](#non-api-commands).

Additionally, every API command understands the following options:

    -e, --api-endpoint URL           Travis API server to talk to
        --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
    -t, --token [ACCESS_TOKEN]       access token to use
        --debug                      show API requests
        --adapter ADAPTER            Faraday adapter to use for HTTP requests

You can supply an access token via `--token` if you want to make an authenticated call. If you don't have an access token stored for the API endpoint, it will remember it for subsequent requests. Keep in mind, this is not the "Travis token" used when setting up GitHub hooks (due to security). You probably don't have an access token handy right now. Don't worry, usually you won't use this option but instead just do a [`travis login`](#login).

The `--debug` option will print HTTP requests to STDERR. Like `--explode`, this is really helpful when contributing to this project.

There are many libraries out there to do HTTP requests in Ruby. You can switch amongst common ones with `--adapter`:

``` console
$ travis show --adapter net-http
...
$ gem install excon
...
$ travis show --adapter excon
...
```

#### `accounts`

The accounts command can be used to list all the accounts you can set up repositories for.

``` console
$ travis accounts
rkh (Konstantin Haase): subscribed, 160 repositories
sinatra (Sinatra): subscribed, 9 repositories
rack (Official Rack repositories): subscribed, 3 repositories
travis-ci (Travis CI): subscribed, 57 repositories
...
```

#### `console`

Provides an interactive shell via [pry](http://pry.github.io/).

Running `travis console` gives you an interactive Ruby session with all the [entities](#entities) imported into global namespace.

This has advantages over `irb -r travis`, such as:
* It will take care of authentication, setting the correct endpoint, etc.
* It also allows you to pass in `--debug` if you are curious as to what's actually going on.

``` console
$ travis console
>> User.current
=> #<User: rkh>
>> Repository.find('sinatra/sinatra')
=> #<Repository: sinatra/sinatra>
>> _.last_build
=> #<Travis::Client::Build: sinatra/sinatra#360>
```

    Interactive shell; requires `pry`.
    Usage: travis console [OPTIONS]
    -h, --help                       Display help
    -i, --[no-]interactive           be interactive and colorful
    -E, --[no-]explode               don't rescue exceptions
        --skip-version-check         don't check if travis client is up to date
        --skip-completion-check      don't check if auto-completion is set up
    -e, --api-endpoint URL           Travis API server to talk to
    -I, --[no-]insecure              do not verify SSL certificate of API endpoint
        --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        --staging                    talks to staging system
    -t, --token [ACCESS_TOKEN]       access token to use
        --debug                      show API requests
        --debug-http                 show HTTP(S) exchange
    -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
        --adapter ADAPTER            Faraday adapter to use for HTTP requests
    -x, --eval LINE                  run line of ruby

#### `endpoint`

Prints out the API endpoint you're talking to.

``` console
$ travis endpoint
API endpoint: https://api.travis-ci.org/
```

Handy for using it when working with shell scripts:

``` console
$ curl "$(travis endpoint)/docs" > docs.html
```

It can also be used to set the default API endpoint used for [General API Commands](#general-api-commands):

``` console
$ travis endpoint --com --set-default
API endpoint: https://api.travis-ci.com/ (stored as default)
```

You can use `--drop-default` to remove the setting again:

``` console
$ travis endpoint --drop-default
default API endpoint dropped (was https://api.travis-ci.com/)
```

#### `login`

The `login` command will, well, log you in. That way, all subsequent commands that run against the same endpoint will be authenticated.

``` console
$ travis login --pro --github-token ghp_********
Successfully logged in as rkh!
```

You need to use a GitHub token and supply it via `--github-token`. Travis CI will not store the token, though - after all, it already should have a valid token for you in the database.
*NOTE*: When creating a GitHub token, see [GitHub Permissions used by travis-ci.com](https://docs.travis-ci.com/user/github-oauth-scopes/#travis-ci-for-private-projects) or [GitHub Permissions used by travis-ci.org](https://docs.travis-ci.com/user/github-oauth-scopes/#travis-ci-for-open-source-projects). The token permissions are dependent on use of travis-ci.com or travis-ci.org and not if they are public or private repositories.

A third option is for the really lazy: `--auto`. In this mode the client will try to find a GitHub token for you and just use that. This will only work if you have a [global GitHub token](https://help.github.com/articles/git-over-https-using-oauth-token) stored in your [.netrc](http://blogdown.io/c4d42f87-80dd-45d5-8927-4299cbdf261c/posts/574baa68-f663-4dcf-88b9-9d41310baf2f). If you haven't heard of this, it's worth looking into in general. Again: Travis CI will not store that token.

#### `logout`

This command makes Travis CI forget your access token.

``` console
$ travis logout --com
Successfully logged out!
```

#### `monitor`

    Usage: travis monitor [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
        -m, --my-repos                   Only monitor my own repositories
        -r, --repo SLUG                  monitor given repository (can be used more than once)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -n, --[no-]notify [TYPE]         send out desktop notifications (optional type: osx, growl, libnotify)
        -b, --builds                     only monitor builds, not jobs
        -p, --push                       monitor push events
        -P, --pull                       monitor pull request events

With `monitor` you can watch a live stream of what's going on:

``` console
$ travis monitor
Monitoring travis-ci.org:
2013-08-05 01:22:40 questmaster/FATpRemote#45 started
2013-08-05 01:22:40 questmaster/FATpRemote#45.1 started
2013-08-05 01:22:41 grangier/python-goose#33.1 passed
2013-08-05 01:22:42 plataformatec/simple_form#666 passed
...
```

You can limit it to a single repository via `--repo SLUG`.

By default, you will receive events for both builds and jobs, you can limit it to builds only via `--build` (short `-b`):

``` console
$ travis monitor
Monitoring travis-ci.org:
2013-08-05 01:22:40 questmaster/FATpRemote#45 started
2013-08-05 01:22:42 plataformatec/simple_form#666 passed
...
```

Similarly, you can limit it to builds/jobs for pull requests via `--pull` and for normal pushes via `--push`.

The monitor command can also send out [desktop notifications](#desktop-notifications):

``` console
$ travis monitor --com -n
Monitoring travis-ci.com:
...
```

When monitoring specific repositories, notifications will be turned on by default. Disable with `--no-notify`.

#### `raw`

This is really helpful both when working on this client and when exploring the [Travis API](https://api.travis-ci.org). It will simply fire a request against the API endpoint, parse the output and pretty print it. Keep in mind that the client takes care of authentication for you:

``` console
$ travis raw /repos/travis-ci/travis.rb
{"repo"=>
  {"id"=>409371,
   "slug"=>"travis-ci/travis.rb",
   "description"=>"Travis CI Client (CLI and Ruby library)",
   "last_build_id"=>4251410,
   "last_build_number"=>"77",
   "last_build_state"=>"passed",
   "last_build_duration"=>351,
   "last_build_language"=>nil,
   "last_build_started_at"=>"2013-01-19T18:00:49Z",
   "last_build_finished_at"=>"2013-01-19T18:02:17Z"}}
```

Use `--json` if you'd rather prefer the output to be JSON.

#### `report`

When inspecting a bug or reporting an issue, it can be handy to include a report about the system and configuration used for running a command.

``` console
$ travis report --com
System
Ruby:                     Ruby 2.0.0-p195
Operating System:         Mac OS X 10.8.5
RubyGems:                 RubyGems 2.0.7

CLI
Version:                  1.5.8
Plugins:                  "travis-as-user", "travis-build", "travis-cli-pr"
Auto-Completion:          yes
Last Version Check:       2013-11-02 16:25:03 +0100

Session
API Endpoint:             https://api.travis-ci.com/
Logged In:                as "rkh"
Verify SSL:               yes
Enterprise:               no

Endpoints
pro:                      https://api.travis-ci.com/ (access token, current)
org:                      https://api.travis-ci.org/ (access token)

Last Exception
An error occurred running `travis whoami --com`:
    Travis::Client::Error: access denied
        from ...


For issues with the command line tool, please visit https://github.com/travis-ci/travis.rb/issues.
For Travis CI in general, go to https://github.com/travis-ci/travis-ci/issues or email support@travis-ci.com.
```

This command can also list all known repos and the endpoint to use for them via the `--known-repos` option.

#### `repos`

    Lists repositories the user has certain permissions on.
    Usage: travis repos [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
            --skip-completion-check      don't check if auto-completion is set up
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -m, --match PATTERN              only list repositories matching the given pattern (shell style)
        -o, --owner LOGIN                only list repos for a certain owner
        -n, --name NAME                  only list repos with a given name
        -a, --active                     only list active repositories
        -A, --inactive                   only list inactive repositories
        -d, --admin                      only list repos with (or without) admin access
        -D, --no-admin                   only list repos without admin access

Lists repositories and displays whether these are active or not. Has a variety of options to filter repositories.

``` console
$ travis repos -m 'rkh/travis-*'
rkh/travis-chat (active: yes, admin: yes, push: yes, pull: yes)
Description: example app demoing travis-sso usage

rkh/travis-encrypt (active: yes, admin: yes, push: yes, pull: yes)
Description: proof of concept in browser encryption of travis settings

rkh/travis-lite (active: no, admin: yes, push: yes, pull: yes)
Description: Travis CI without the JavaScript

rkh/travis-surveillance (active: no, admin: yes, push: yes, pull: yes)
Description: Veille sur un projet.
```

In non-interactive mode, it will only output the repository slug, which goes well with xargs:

``` console
$ travis repos --active --owner travis-ci | xargs -I % travis disable -r %
travis-ci/artifacts: disabled :(
travis-ci/canary: disabled :(
travis-ci/docs-travis-ci-com: disabled :(
travis-ci/dpl: disabled :(
travis-ci/gh: disabled :(
...
```

#### `sync`

    Usage: travis sync [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -c, --check                      only check the sync status
        -b, --background                 will trigger sync but not block until sync is done
        -f, --force                      will force sync, even if one is already running

Sometimes the info Travis CI has about users and repositories become out of date. If that should happen, you can manually trigger a sync:

``` console
$ travis sync
synchronizing: ........... done
```

The command blocks until the synchronization is done. You can avoid that with `--background`:

``` console
$ travis sync --background
starting synchronization
```

If you just want to know if your account is being synchronized right now, use `--check`:

``` console
$ travis sync --check
rkh is currently syncing
```

#### `lint`

This checks a `.travis.yml` file for any issues it might detect.

By default, it will read a file named `.travis.yml` in the current directory:

``` console
$ travis lint
Warnings for .travis.yml:
[x] your repository must be feature flagged for the os setting to be used
```

You can also give it a path to a different file:

``` console
$ travis lint example.yml
...
```

Or pipe the content into it:

``` console
$ echo "foo: bar" | travis lint
Warnings for STDIN:
[x] unexpected key foo, dropping
[x] missing key language, defaulting to ruby
```

Like the [`status` command](#status), you can use `-q` to suppress any output, and `-x` to have it set the exit code to 1 if there are any warnings.

``` console
$ travis lint -qx || echo ".travis.yml does not validate"
```

#### `token`

In order to use the Ruby library you will need to obtain an access token first. To do this simply run the `travis login` command. Once logged in you can check your token with `travis token`:

``` console
$ travis token
Your access token is super-secret
```

You can use that token for instance with curl:

``` console
$ curl -H "Authorization: token $(travis token)" https://api.travis-ci.org/users/
{"login":"rkh","name":"Konstantin Haase","email":"konstantin.haase@gmail.com","gravatar_id":"5c2b452f6eea4a6d84c105ebd971d2a4","locale":"en","is_syncing":false,"synced_at":"2013-01-21T20:31:06Z"}
```

Note that if you just need it for looking at API payloads, that we also have the [`raw`](#raw) command.

#### `whatsup`

It's just a tiny feature, but it allows you to take a look at repositories that have recently seen some action (ie the left hand sidebar on [travis-ci.org](https://travis-ci.org)):

``` console
$ travis whatsup
mysociety/fixmystreet started: #154
eloquent/typhoon started: #228
Pajk/apipie-rails started: #84
qcubed/framework failed: #21
...
```

If you only want to see what happened in your repositories, add the `--my-repos` flag (short: `-m`):

``` console
$ travis whatsup -m
travis-ci/travis.rb passed: #169
rkh/dpl passed: #50
rubinius/rubinius passed: #3235
sinatra/sinatra errored: #619
rtomayko/tilt failed: #162
ruby-no-kai/rubykaigi2013 passed: #50
rack/rack passed: #519
...
```

#### `whoami`

This command is useful to verify that you're in fact logged in:

``` console
$ travis whoami
You are rkh (Konstantin Haase)
```

Again, like most other commands, goes well with shell scripting:

``` console
$ git clone "https://github.com/$(travis whoami)/some_project"
```

### Repository Commands

    -h, --help                       Display help
    -i, --[no-]interactive           be interactive and colorful
    -E, --[no-]explode               don't rescue exceptions
        --skip-version-check         don't check if travis client is up to date
        --skip-completion-check      don't check if auto-completion is set up
    -e, --api-endpoint URL           Travis API server to talk to
    -I, --[no-]insecure              do not verify SSL certificate of API endpoint
        --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
        --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
    -t, --token [ACCESS_TOKEN]       access token to use
        --debug                      show API requests
    -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
    -r, --repo SLUG                  repository to use (will try to detect from current git clone)
    -R, --store-repo SLUG            like --repo, but remembers value for current directory

Repository commands have all the options [General API Commands](#general-api-commands) have.

Additionally, you can specify the Repository to talk to by providing `--repo owner/name`. However, if you invoke the command inside a clone of the project, the client will figure out this option on its own. Note that it uses the tracked [git remote](http://www.kernel.org/pub/software/scm/git/docs/git-remote.html) for the current branch (and defaults to 'origin' if no tracking is set) to do so. You can use `--store-repo SLUG` once to override it permanently.

It will also automatically pick [travis-ci.com](https://travis-ci.com) if it is a private project. You can of course override this decision with `--com`, `--org` or `--api-endpoint URL`

#### `branches`

Displays the most recent build for each branch:

``` console
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
```

For more fine grained control and older builds on a specific branch, see [`history`](#history).

#### `cache`

    Lists or deletes repository caches.
    Usage: travis cache [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
            --skip-completion-check      don't check if auto-completion is set up
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -d, --delete                     delete listed caches
        -b, --branch BRANCH              only list/delete caches on given branch
        -m, --match STRING               only list/delete caches where slug matches given string
        -f, --force                      do not ask user to confirm deleting the caches

Lists or deletes [directory caches](http://about.travis-ci.org/docs/user/caching/) for a repository:

``` console
$ travis cache
On branch master:
cache--rvm-2.0.0--gemfile-Gemfile      last modified: 2013-11-04 13:45:44  size: 62.21 MiB
cache--rvm-ruby-head--gemfile-Gemfile  last modified: 2013-11-04 13:46:55  size: 62.65 MiB

On branch example:
cache--rvm-2.0.0--gemfile-Gemfile      last modified: 2013-11-04 13:45:44  size: 62.21 MiB

Overall size of above caches: 187.07 MiB
```

You can filter by branch:

``` console
$ travis cache --branch master
On branch master:
cache--rvm-2.0.0--gemfile-Gemfile      last modified: 2013-11-04 13:45:44  size: 62.21 MiB
cache--rvm-ruby-head--gemfile-Gemfile  last modified: 2013-11-04 13:46:55  size: 62.65 MiB

Overall size of above caches: 124.86 MiB
```

And by matching against the slug:

``` console
$ travis cache --match 2.0.0
On branch master:
cache--rvm-2.0.0--gemfile-Gemfile  last modified: 2013-11-04 13:45:44  size: 62.21 MiB

Overall size of above caches: 62.21 MiB
```

You can also use this command to delete caches:

``` console
$ travis cache -b example -m 2.0.0 --delete
DANGER ZONE: Do you really want to delete all caches on branch example that match 2.0.0? |no| yes
Deleted the following caches:

On branch example:
cache--rvm-2.0.0--gemfile-Gemfile  last modified: 2013-11-04 13:45:44  size: 62.21 MiB

Overall size of above caches: 62.21 MiB
```

#### `cancel`

This command will cancel the latest build:

``` console
$ travis cancel
build #85 has been canceled
```

You can also cancel any build by giving a build number:

``` console
$ travis cancel 57
build #57 has been canceled
```

Or a single job:

``` console
$ travis cancel 57.1
job #57.1 has been canceled
```

#### `disable`

If you want to turn off a repository temporarily or indefinitely, you can do so with the `disable` command:

``` console
$ travis disable
travis-ci/travis.rb: disabled :(
```

#### `enable`

With the `enable` command, you can easily activate a project on Travis CI:

``` console
$ travis enable
travis-ci/travis.rb: enabled :)
```

It even works when enabling a repo Travis didn't know existed by triggering a sync:

``` console
$ travis enable -r rkh/test
repository not known to Travis CI (or no access?)
triggering sync: ............. done
rkh/test: enabled
```

If you don't want the sync to be triggered, use `--skip-sync`.

#### `encrypt`

    Encrypts values for the .travis.yml.
    Usage: travis encrypt [ARGS..] [OPTIONS]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
            --skip-completion-check      don't check if auto-completion is set up
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
            --staging                    talks to staging system
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --debug-http                 show HTTP(S) exchange
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -a, --add [KEY]                  adds it to .travis.yml under KEY (default: env.global)
        -s, --[no-]split                 treat each line as a separate input
        -p, --append                     don't override existing values, instead treat as list
        -x, --override                   override existing value

This command is useful to encrypt [environment variables](http://about.travis-ci.org/docs/user/encryption-keys/) or deploy keys for private dependencies.

``` console
$ travis encrypt FOO=bar
Please add the following to your .travis.yml file:

  secure: "gSly+Kvzd5uSul15CVaEV91ALwsGSU7yJLHSK0vk+oqjmLm0jp05iiKfs08j\n/Wo0DG8l4O9WT0mCEnMoMBwX4GiK4mUmGdKt0R2/2IAea+M44kBoKsiRM7R3\n+62xEl0q9Wzt8Aw3GCDY4XnoCyirO49DpCH6a9JEAfILY/n6qF8="

Pro Tip™: You can add it automatically by running with --add.
```

For deploy keys, it is really handy to pipe them into the command:

``` console
$ cat id_rsa | travis encrypt
```

Another use case for piping files into it: If you have a file with sensitive environment variables, like foreman's [.env](http://ddollar.github.com/foreman/#ENVIRONMENT) file, you can tell the client to encrypt every line separately via `--split`:

``` console
$ cat .env | travis encrypt --split
Please add the following to your .travis.yml file:

  secure: "KmMdcwTWGubXVRu93/lY1NtyHxrjHK4TzCfemgwjsYzPcZuPmEA+pz+umQBN\n1ZhzUHZwDNsDd2VnBgYq27ZdcS2cRvtyI/IFuM/xJoRi0jpdTn/KsXR47zeE\nr2bFxRqrdY0fERVHSMkBiBrN/KV5T70js4Y6FydsWaQgXCg+WEU="
  secure: "jAglFtDjncy4E3upL/RF0ZOcmJ2UMrqHFCLQwU8PBdurhTMBeTw+IO6cXx5z\nU5zqvPYo/ghZ8mMuUhvHiGDM6m6OlMP7+l10VTxH1CoVew2NcQvRdfK3P+4S\nZJ43Hyh/ZLCjft+JK0tBwoa3VbH2+ZTzkRZQjdg54bE16C7Mf1A="

Pro Tip: You can add it automatically by running with --add.
```

As suggested, the client can also add them to your `.travis.yml` for you:

``` console
$ travis encrypt FOO=bar --add
```

This will by default add it as global variables for every job. You can also add it as matrix entries by providing a key:

``` console
$ travis encrypt FOO=bar --add env.matrix
```

There are two ways the client can treat existing values:

* Turn existing value into a list if it isn't already, append new value to that list. This is the default behavior for keys that start with `env.` and can be enforced with `--append`.
* Replace existing value. This is the default behavior for keys that do not start with `env.` and can be enforced with `--override`.

#### `encrypt-file`

    Encrypts a file and adds decryption steps to .travis.yml.
    Usage: travis encrypt-file INPUT_PATH [OUTPUT_PATH] [OPTIONS]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
            --skip-completion-check      don't check if auto-completion is set up
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --pro                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
            --staging                    talks to staging system
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --debug-http                 show HTTP(S) exchange
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -K, --key KEY                    encryption key to be used (randomly generated otherwise)
            --iv IV                      encryption IV to be used (randomly generated otherwise)
        -d, --decrypt                    decrypt the file instead of encrypting it, requires key and iv
        -f, --force                      override output file if it exists
        -p, --print-key                  print (possibly generated) key and iv
        -w, --decrypt-to PATH            where to write the decrypted file to on the Travis CI VM
        -a, --add [STAGE]                automatically add command to .travis.yml (default stage is before_install)

This command will encrypt a file for you using a symmetric encryption (AES-256), and it will store the secret in a [secure variable](#env). It will output the command you can use in your build script to decrypt the file.

``` console
$ travis encrypt-file bacon.txt
encrypting bacon.txt for rkh/travis-encrypt-file-example
storing result as bacon.txt.enc
storing secure env variables for decryption

Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_0a6446eb3ae3_key -iv $encrypted_0a6446eb3ae3_key -in bacon.txt.enc -out bacon.txt -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add bacon.txt.enc to the git repository.
Make sure not to add bacon.txt to the git repository.
Commit all changes to your .travis.yml.
```

You can also use `--add` to have it automatically add the decrypt command to your `.travis.yml`

``` console
$ travis encrypt-file bacon.txt --add
encrypting bacon.txt for rkh/travis-encrypt-file-example
storing result as bacon.txt.enc
storing secure env variables for decryption

Make sure to add bacon.txt.enc to the git repository.
Make sure not to add bacon.txt to the git repository.
Commit all changes to your .travis.yml.
```

#### `env`

    Show or modify build environment variables.

    Usage: travis env list [options]
           travis env set name value [options]
           travis env unset [names..] [options]
           travis env copy [names..] [options]
           travis env clear [OPTIONS]

        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
            --skip-completion-check      don't check if auto-completion is set up
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
            --staging                    talks to staging system
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
            --as USER                    authenticate as given user
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -P, --[no-]public                make new values public
        -p, --[no-]private               make new values private
        -u, --[no-]unescape              do not escape values
        -f, --force                      do not ask for confirmation when clearing out all variables

You can set, list and unset environment variables, or copy them from the current environment:

``` console
$ travis env set foo bar --public
[+] setting environment variable $foo
$ travis env list
# environment variables for travis-ci/travis.rb
foo=bar

$ export foo=foobar
$ travis env copy foo bar
[+] setting environment variable $foo
[+] setting environment variable $bar
$ travis env list
# environment variables for travis-ci/travis.rb
foo=foobar
bar=[secure]
$ travis env unset foo bar
[x] removing environment variable $foo
[x] removing environment variable $bar
```

#### `history`

    Displays a project's build history.
    Usage: travis history [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
            --skip-completion-check      don't check if auto-completion is set up
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -a, --after BUILD                Only show history after a given build number
        -p, --pull-request NUMBER        Only show history for the given Pull Request
        -b, --branch BRANCH              Only show history for the given branch
        -l, --limit LIMIT                Maximum number of history items
        -d, --date                       Include date in output
            --[no-]all                   Display all history items

You can check out what the recent builds look like:

``` console
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
```

By default, it will display the last 10 builds. You can limit (or extend) the number of builds with `--limit`:

``` console
$ travis history --limit 2
#77 passed:   master fix name clash
#76 failed:   master Merge pull request #11 from travis-ci/rkh-show-logs-history
```

You can use `--after` to display builds after a certain build number (or, well, before, but it's called after to use the same phrases as the API):

``` console
$ travis history --limit 2 --after 76
#75 passed:   rkh-debug what?
#74 passed:   rkh-debug all tests pass locally and on the travis vm I spin up :(
```

You can also limit the history to builds for a certain branch:

``` console
$ travis history --limit 3 --branch master
#77 passed:   master fix name clash
#76 failed:   master Merge pull request #11 from travis-ci/rkh-show-logs-history
#57 passed:   master Merge pull request #5 from travis-ci/hh-multiline-encrypt
```

Or a certain Pull Request:

``` console
$ travis history --limit 3 --pull-request 5
#56 passed:   Pull Request #5 Merge branch 'master' into hh-multiline-encrypt
#49 passed:   Pull Request #5 improve output
#48 passed:   Pull Request #5 let it generate accessor for line splitting automatically
```

#### `init`

    Usage: travis init [language] [file] [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
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

``` console
$ travis init java
.travis.yml file created!
travis-ci/java-example: enabled :)
```

You can also set certain values via command line flags (see list above):

``` console
$ travis init c --compiler clang
.travis.yml file created!
travis-ci/c-example: enabled :)
```

#### `logs`

Given a job number, logs simply prints out that job's logs. By default it will display the first job of the latest build.

``` console
$ travis logs
displaying logs for travis-ci/travis.rb#317.1
[... more logs ...]
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
$ bundle exec rake
/home/travis/.rvm/rubies/ruby-1.8.7-p371/bin/ruby -S rspec spec -c
..............................................................................................................................................................................................................................................................................

Finished in 4.46 seconds
270 examples, 0 failures

Done. Build script exited with: 0
```

The info line about the job being displayed is written to stderr, the logs itself are written to stdout.

It takes an optional argument that can be a job number:

``` console
$ travis logs 100.3
displaying logs for travis-ci/travis.rb#100.3
```

A build number (in which case it will pick the build's first job):

``` console
$ travis logs 100
displaying logs for travis-ci/travis.rb#100.1
```

Just the job suffix, which will pick the corresponding job from the latest build:

``` console
$ travis logs .2
displaying logs for travis-ci/travis.rb#317.2
```

A branch name:

``` console
$ travis logs ghe
displaying logs for travis-ci/travis.rb#270.1
```

You can delete the logs with the `--delete` flag, which optionally takes a reason as argument:

``` console
$ travis logs --delete
DANGER ZONE: Do you really want to delete the build log for travis-ci/travis.rb#559.1? |no| yes
deleting log for travis-ci/travis.rb#559.1
$ travis logs 1.7 --delete "contained confidential data" --force
deleting log for travis-ci/travis.rb#1.7
```

#### `open`

Opens the project view in the Travis CI web interface. If you pass it a build or job number, it will open that specific view:

``` console
$ travis open
```

If you just want the URL printed out instead of opened in a browser, pass `--print`.

If instead you want to open the repository, compare or pull request view on GitHub, use `--github`.

``` console
$ travis open 56 --print --github
web view: https://github.com/travis-ci/travis.rb/pull/5
```

#### `pubkey`

Outputs the public key for a repository.

``` console
$ travis pubkey
Public key for travis-ci/travis.rb:

ssh-rsa ...
$ travis pubkey -r rails/rails > rails.key
```

The `--pem` flag will print out the key PEM encoded:

``` console
$ travis pubkey --pem
Public key for travis-ci/travis.rb:

-----BEGIN PUBLIC KEY-----
...
-----END PUBLIC KEY-----
```

Whereas the `--fingerprint` flag will print out the key's fingerprint:

``` console
$ travis pubkey --fingerprint
Public key for travis-ci/travis.rb:

9f:57:01:4b:af:42:67:1e:b4:3c:0f:b6:cd:cc:c0:04
```

#### `requests`

With the `requests` command, you can list the build requests received by Travis CI from GitHub. This is handy for figuring out why a repository might not be building.

``` console
$ travis requests -r sinatra/sinatra
push to master accepted (triggered new build)
  abc51e2 - Merge pull request #847 from gogotanaka/add_readme_ja
  received at: 2014-02-16 09:26:36

PR #843 rejected (skipped through commit message)
  752201c - Update Spanish README with tense, verb, and word corrections. [ci skip]
  received at: 2014-02-16 05:07:16
```

You can use `-l`/`--limit` to limit the number of requests displayed.

#### `restart`

This command will restart the latest build:

``` console
$ travis restart
build #85 has been restarted
```

You can also restart any build by giving a build number:

``` console
$ travis restart 57
build #57 has been restarted
```

Or a single job:

``` console
$ travis restart 57.1
job #57.1 has been restarted
```

##### `settings`

Certain repository settings can be read via the CLI:

``` console
$ travis settings
Settings for travis-ci/travis.rb:
[-] builds_only_with_travis_yml    Only run builds with a .travis.yml
[+] build_pushes                   Build pushes
[+] build_pull_requests            Build pull requests
[-] maximum_number_of_builds       Maximum number of concurrent builds
```

You can also filter the settings by passing them in as arguments:

``` console
$ travis settings build_pushes build_pull_requests
Settings for travis-ci/travis.rb:
[+] build_pushes                   Build pushes
[+] build_pull_requests            Build pull requests
```

It is also possible to change these settings via `--enable`, `--disable` and `--set`:

``` console
$ travis settings build_pushes --disable
Settings for travis-ci/travis.rb:
[-] build_pushes                   Build pushes
$ travis settings maximum_number_of_builds --set 1
Settings for travis-ci/travis.rb:
  1 maximum_number_of_builds       Maximum number of concurrent builds
```

Or, alternatively, you can use `-c` to configure the settings interactively:

``` console
$ travis settings -c
Settings for travis-ci/travis.rb:
Only run builds with a .travis.yml? |yes| no
Build pushes? |no| yes
Build pull requests? |yes|
Maximum number of concurrent builds: |1| 5
```

#### `setup`

Helps you configure Travis addons.

    Usage: travis setup service [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
            --skip-version-check         don't check if travis client is up to date
        -e, --api-endpoint URL           Travis API server to talk to
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
            --adapter ADAPTER            Faraday adapter to use for HTTP requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -f, --force                      override config section if it already exists

Available services: `anynines`, `appfog`, `artifacts`, `biicode`, `cloudcontrol`, `cloudfiles`, `cloudfoundry`, `cloud66`, `codedeploy`, `deis`, `divshot`, `elasticbeanstalk`, `engineyard`, `gcs`, `hackage`, `heroku`, `modulus`, `npm`, `ninefold`, `nodejitsu`, `openshift`, `opsworks`, `pypi`, `releases`, `rubygems`, `s3` and `sauce_connect`.

Example:

``` console
$ travis setup heroku
Deploy only from travis-ci/travis-chat? |yes|
Encrypt API key? |yes|
```

#### `show`

Displays general info about the latest build:

``` console
$ travis show
Build #77: fix name clash
State:         passed
Type:          push
Compare URL:   https://github.com/travis-ci/travis.rb/compare/7cc9b739b0b6...39b66ee24abe
Duration:      5 min 51 sec
Started:       2013-01-19 19:00:49
Finished:      2013-01-19 19:02:17

#77.1 passed:    45 sec         rvm: 1.8.7
#77.2 passed:    50 sec         rvm: 1.9.2
#77.3 passed:    45 sec         rvm: 1.9.3
#77.4 passed:    46 sec         rvm: 2.0.0
#77.5 failed:    1 min 18 sec   rvm: jruby (failure allowed)
#77.6 passed:    1 min 27 sec   rvm: rbx
```

Any other build:

``` console
$ travis show 1
Build #1: add .travis.yml
State:         failed
Type:          push
Compare URL:   https://github.com/travis-ci/travis.rb/compare/ad817bc37c76...b8c5d3b463e2
Duration:      3 min 16 sec
Started:       2013-01-13 23:15:22
Finished:      2013-01-13 23:21:38

#1.1 failed:     21 sec         rvm: 1.8.7
#1.2 failed:     34 sec         rvm: 1.9.2
#1.3 failed:     24 sec         rvm: 1.9.3
#1.4 failed:     52 sec         rvm: 2.0.0
#1.5 failed:     38 sec         rvm: jruby
#1.6 failed:     27 sec         rvm: rbx
```

The last build for a given branch:

``` console
$ travis show rkh-debug
Build #75: what?
State:         passed
Type:          push
Branch:        rkh-debug
Compare URL:   https://github.com/travis-ci/travis.rb/compare/8d4aa5254359...7ef33d5e5993
Duration:      6 min 16 sec
Started:       2013-01-19 18:51:17
Finished:      2013-01-19 18:52:43

#75.1 passed:    1 min 10 sec   rvm: 1.8.7
#75.2 passed:    51 sec         rvm: 1.9.2
#75.3 passed:    36 sec         rvm: 1.9.3
#75.4 passed:    48 sec         rvm: 2.0.0
#75.5 failed:    1 min 26 sec   rvm: jruby (failure allowed)
#75.6 passed:    1 min 25 sec   rvm: rbx
```

Or a job:

``` console
$ travis show 77.3
Job #77.3: fix name clash
State:         passed
Type:          push
Compare URL:   https://github.com/travis-ci/travis.rb/compare/7cc9b739b0b6...39b66ee24abe
Duration:      45 sec
Started:       2013-01-19 19:00:49
Finished:      2013-01-19 19:01:34
Allow Failure: false
Config:        rvm: 1.9.3
```

#### `sshkey`

    Checks, updates or deletes an SSH key.
    Usage: travis sshkey [OPTIONS]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
        -I, --[no-]insecure              do not verify SSL certificate of API endpoint
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -X, --enterprise [NAME]          use enterprise setup (optionally takes name for multiple setups)
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -D, --delete                     remove SSH key
        -d, --description DESCRIPTION    set description
        -u, --upload FILE                upload key from given file
        -s, --stdin                      upload key read from stdin
        -c, --check                      set exit code depending on key existing
        -g, --generate                   generate SSH key and set up for given GitHub user
        -p, --passphrase PASSPHRASE      pass phrase to decrypt with when using --upload

*This feature is for [private and Enterprise](#travis-ci-and-travis-ci-enterprise) only.*

With the `sshkey` command you can check if there is a custom SSH key set up. Custom SSH keys are used for cloning the repository.

``` console
$ travis sshkey
No custom SSH key installed.
```

You can also use it to upload an SSH key:

``` console
$ travis sshkey --upload ~/.ssh/id_rsa
Key description: Test Key
updating ssh key for travis-pro/test-project with key from /Users/konstantin/.ssh/id_rsa
Current SSH key: Test Key
```

And to remove it again:

``` console
$ travis sshkey --delete
DANGER ZONE: Remove SSH key for travis-pro/test-project? |no| yes
removing ssh key for travis-pro/test-project
No custom SSH key installed.
```

You can also have it generate a key for a given GitHub user (for instance, for a dedicated CI user that only has read access). The public key will automatically be added to GitHub and the private key to Travis CI:

``` console
$ travis sshkey --generate
We need the GitHub login for the account you want to add the key to.
This information will not be sent to Travis CI, only to api.github.com.
The password will not be displayed.

Username: travisbot
Password for travisbot: **************

Generating RSA key.
Uploading public key to GitHub.
Uploading private key to Travis CI.
```

See [Private Dependencies](https://docs.travis-ci.com/user/private-dependencies/) for an in-detail description.

#### `status`

    Usage: travis status [options]
        -h, --help                       Display help
        -i, --[no-]interactive           be interactive and colorful
        -E, --[no-]explode               don't rescue exceptions
        -e, --api-endpoint URL           Travis API server to talk to
            --com                        short-cut for --api-endpoint 'https://api.travis-ci.com/'
            --org                        short-cut for --api-endpoint 'https://api.travis-ci.org/'
        -t, --token [ACCESS_TOKEN]       access token to use
            --debug                      show API requests
        -r, --repo SLUG                  repository to use (will try to detect from current git clone)
        -R, --store-repo SLUG            like --repo, but remembers value for current directory
        -x, --[no-]exit-code             sets the exit code to 1 if the build failed
        -q, --[no-]quiet                 does not print anything
        -p, --[no-]fail-pending          sets the status code to 1 if the build is pending

Outputs a one line status message about the project's last build. With `-q` that line will even not be printed out. How's that useful? Combine it with `-x` and the exit code will be 1 if the build failed, with `-p` and it will be 1 for a pending build.

``` console
$ travis status -qpx && cap deploy
```

### Travis CI and Travis CI Enterprise

By default, [General API Commands](#general-api-commands) will talk to [api.travis-ci.org](https://api.travis-ci.org). You can change this by supplying `--com` for [api.travis-ci.com](https://api.travis-ci.com) or `--api-endpoint` with your own endpoint. Note that all [Repository Commands](#repository-commands) will try to figure out the API endpoint to talk to automatically depending on the project's visibility on GitHub.

``` console
$ travis login --com
...
$ travis monitor --com -m
...
```

The custom `--api-endpoint` option is handy for local development:

``` console
$ travis whatsup --api-endpoint http://localhost:3000
...
```

If you have a Travis Enterprise setup in house, you can use the `--enterprise` option (or short `-X`). It will ask you for the enterprise domain the first time it is used.

``` console
$ travis login -X
Enterprise domain: travisci.example.com
...
$ travis whatsup -X
...
```

Note that currently [Repository Commands](#repository-commands) will not be able to detect Travis Enterprise automatically. You will have to use the `-X` flag at least once per repository. The command line tool will remember the API endpoint for subsequent commands issued against the same repository.

### Environment Variables

You can set the following environment variables to influence the travis behavior:

* `$TRAVIS_TOKEN` - access token to use when the `--token` flag is not used
* `$TRAVIS_ENDPOINT` - API endpoint to use when the `--api-endpoint`, `--org` or `--com` flag is not used
* `$TRAVIS_CONFIG_PATH` - directory to store configuration in (defaults to ~/.travis)

### Desktop Notifications

Some commands support sending desktop notifications. The following notification systems are currently supported:

* **Notification Center** - requires Mac OSX 10.8 or later and [Notification Center](http://support.apple.com/kb/ht5362) must be running under the system executing the `travis` command.
* **Growl** - [growlnotify](http://growl.info/downloads#generaldownloads) has to be installed and [Growl](https://itunes.apple.com/us/app/growl/id467939042?mt=12&ign-mpt=uo%3D4) needs to be running. Does currently not support the Windows version of Growl.
* **libnotify** - needs [libnotify](http://www.linuxfromscratch.org/blfs/view/svn/x/libnotify.html) installed, including the `notify-send` executable.

### Plugins

The `travis` binary has rudimentary support for plugins: It tries to load all files matching `~/.travis/*/init.rb`. Note that the APIs plugins use are largely semi-private. That is, they should remain stable, but are not part of the public API covered by semantic versioning. You can list the installed plugins via [`travis report`](#report).

It is possible to define new commands directly in the [init.rb](https://github.com/travis-ci/travis-build/blob/master/init.rb) or to set up [lazy-loading](https://github.com/travis-ci/travis-cli-pr/blob/master/init.rb) for these.

#### Official Plugins

* [travis-cli-gh](https://github.com/travis-ci/travis-cli-gh#readme): Plugin for interacting with the GitHub API.

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

So, which one to choose? The global style has one session, whereas with the client style, you have one session per client instance. Each session has its own cache and identity map. This might matter for long running processes. If you use a new session for separate units of work, you can be pretty sure to not leak any objects. On the other hand using the constants or reusing the same session might save you from unnecessary HTTP requests.

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

There is also `travis/auto_login`, which will try to read the CLI configuration or .netrc for a Travis CI or GitHub token to authenticate with automatically:

``` ruby
require 'travis/auto_login'
puts "Hello #{Travis::User.current.name}!"
```

### Using Pro

Using the library with private projects pretty much works the same, except you use `Travis::Pro`.

Keep in mind that you need to authenticate.

``` ruby
require 'travis/pro'

Travis::Pro.access_token = '...'
user = Travis::Pro::User.current

puts "Hello #{user.name}!"
```

There is also `travis/pro/auto_login`, which will try to read the CLI configuration or .netrc for a Travis CI or GitHub token to authenticate with automatically:

``` ruby
require 'travis/pro/auto_login'
puts "Hello #{Travis::Pro::User.current.name}!"
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

[Repositories](#repositories), [Builds](#builds) and [Jobs](#jobs) all are basically state machines, which means they implement the following methods:

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

repo = Travis::Repository.find('travis-ci/travis.rb')
job  = repo.last_build.jobs.first
puts job.log.body
```

If you plan to print out the body, be aware that it might contain malicious escape codes. For this reason, we added `colorized_body`, which removes all the unprintable characters, except for ANSI color codes, and `clean_body` which also removes the color codes.

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

repo   = Travis::Repository.find('travis-ci/travis.rb')
commit = repo.last_build.commit

puts "Last tested commit: #{commit.short_sha} on #{commit.branch} by #{commit.author_name} - #{commit.subject}"
```

#### Caches

Caches can be fetched for a repository.

``` ruby
require 'travis/pro'

Travis::Pro.access_token = "MY SECRET TOKEN"
repo = Travis::Pro::Repository.find("my/rep")

repo.caches.each do |cache|
  puts "#{cache.branch}: #{cache.size}"
  cache.delete
end
```

It is also possible to delete multiple caches with a single API call:

``` ruby
repo.delete_caches(branch: "master", match: "rbx")
```

#### Repository Settings

You can access a repositories settings via `Repository#settings`:

``` ruby
require 'travis'

Travis.access_token = "MY SECRET TOKEN"
settings = Travis::Repository.find('my/repo').settings

if settings.build_pushes?
  settings.build_pushes  = false
  settings.save
end
```

#### Build Environment Variables

You can access environment variables via `Repository#env_vars`:

``` ruby
require 'travis'

Travis.access_token = "MY SECRET TOKEN"
env_vars = Travis::Repository.find('my/repo').env_vars

env_vars['foo'] = 'bar'
env_vars.upsert('foo', 'foobar', public: true)
env_vars.each { |var| var.delete }
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
session.repo('travis-ci/travis.rb')             # this project
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

Make sure you have at least [Ruby](http://www.ruby-lang.org/en/downloads/) 2.3.0 (2.6.0 recommended) installed.

You can check your Ruby version by running `ruby -v`:

    $ ruby -v
    ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-linux]

Then run:

On OSX and Linux:

    $ gem install travis --no-document

(For older versions of `gem`, replace `--no-document` with `--no-rdoc --no-ri`.)

On Windows:

    $ gem install travis

If you do not have write access to the system gem directory, you'll need to perform a local install by adding ```--user-install```. You also need to ensure the local gem directory is on your PATH.

Now make sure everything is working:

    $ travis version
    1.10.0

See also [Note on Ubuntu](#ubuntu) below.

### Note on Ruby 2.3

For Ruby 2.3.x, be sure to have a compatible version of `faraday` installed; e.g.,

    $ gem install faraday -v 1.0.1

### Development Version

You can also install the development version via RubyGems:

    $ gem install travis --pre

We automatically publish a new development version after every successful build.

### Running Locally

If you want to try out your changes locally:

```
bundle install # install the dependencies
bundle exec bin/travis a-command # run your command
```

### Updating your Ruby

If you have an outdated Ruby version, or your OS doesn't come with Ruby pre-installed,
you should use your package system or a Ruby Installer to install a recent Ruby.

#### Mac OS X via Homebrew

You can use [Homebrew](http://mxcl.github.io/homebrew/) to install a recent version:

    $ brew install ruby
    $ gem update --system

#### Windows

On Windows, we recommend using the [RubyInstaller](http://rubyinstaller.org/), which includes the latest version of Ruby.

#### Other Unix systems

On other Unix systems, like Linux, use your package system to install Ruby.

Debian, Ubuntu:

    $ sudo apt-get update
    $ sudo apt-get install ruby

For other Linux distributions, refer to their respective documentation.

#### Ruby versioning tools

Alternatively, you can use a Ruby version management tool such as [rvm](https://rvm.io/rvm/install/), [rbenv](http://rbenv.org/) or [chruby](https://github.com/postmodern/chruby). This is only recommended if you need to run multiple versions of Ruby.

You can of course always compile Ruby from source, though then you are left with the hassle of keeping it up to date and making sure that everything is set up properly.

### Troubleshooting

#### Upgrading from travis-cli

If you have the old `travis-cli` gem installed, you should `gem uninstall travis-cli`, just to be sure, as it ships with an executable that is also named `travis`.

#### `uninitialized constant Faraday::Error::ConnectionFailed`

You might see this error message if you have Typhoeus version prior to version 1.4.0
and Faraday 1.0 and up.
You can eradicate this problem by either:

1. Update Typhoeus to version 1.4.0 or later
1. Remove typhoeus entirely

See https://github.com/travis-ci/travis.rb/issues/768#issuecomment-700220351 for more details.

## Version History

### 1.10.1

* Fix `travis monitor` command https://github.com/travis-ci/travis.rb/pull/770

### 1.10.0 (September 22, 2020)

* Requires Ruby 2.3.0 or later (2.6.0 or later is recommended)
* Display a meaningful message when Travis API is unavailable. https://github.com/travis-ci/travis.rb/issues/753
* Eschew `which` to find a command on the system. https://github.com/travis-ci/travis.rb/pull/765
* Fix `--list-github-token` flag. https://github.com/travis-ci/travis.rb/pull/766
* FFI is no longer required. https://github.com/travis-ci/travis.rb/pull/758
* Typhoeus is no longer required, but remains supported (used if installed). https://github.com/travis-ci/travis.rb/pull/756

### 1.9.1 (May 19, 2020)

* Fix `--no-interactive` flag in `encrypt` and `encrypt-file` commands https://github.com/travis-ci/travis.rb/pull/738
* Display commit SHA in `show` https://github.com/travis-ci/travis.rb/pull/739
* Display more helpful message when GitHub token given by `--github-token` is
  deficient https://github.com/travis-ci/travis.rb/issues/708
* Fix `--pull-request` flag in `history` command https://github.com/travis-ci/travis.rb/issues/382

### 1.9.0 (April 27, 2020)

* Require Ruby 2.3 and up
* Add Ruby 2.7 support

* Validate `-r` argument form https://github.com/travis-ci/travis.rb/issues/281
* Verify `.travis.yml` is valid before sending to the server https://github.com/travis-ci/travis.rb/issues/706
* Skip version check if rubygems.org is down https://github.com/travis-ci/travis.rb/issues/246
* Documentation updates
  https://github.com/travis-ci/travis.rb/pull/641
  https://github.com/travis-ci/travis.rb/pull/567
  https://github.com/travis-ci/travis.rb/pull/446
  https://github.com/travis-ci/travis.rb/pull/363
  https://github.com/travis-ci/travis.rb/pull/665
  https://github.com/travis-ci/travis.rb/pull/737
* Fix `json` dependency https://github.com/travis-ci/travis.rb/issues/508
* Add `bash` template https://github.com/travis-ci/travis.rb/pull/332
* Add `elixir` template https://github.com/travis-ci/travis.rb/pull/471
* Hardcode `pgrep` path https://github.com/travis-ci/travis.rb/pull/570
* Fix `travis restart` command https://github.com/travis-ci/travis.rb/pull/416
* Define `skip_cleanup` for `setup` command if using `dpl` v1 https://github.com/travis-ci/travis.rb/pull/704
* Prevent `.bashrc` from failing when init file is not present https://github.com/travis-ci/travis.rb/pull/595

### 1.8.13 (April 7, 2020)

* Add support for [`gh`](https://github.com/travis-ci/gh) [0.16.0](https://rubygems.org/gems/gh/versions/0.16.0)

### 1.8.12 (March 23, 2020)

* Fix `encrypt-file` command (https://github.com/travis-ci/travis.rb/pull/715)
* Fix `console` command (https://github.com/travis-ci/travis.rb/issues/654)
* Ask for confirmation when `encrypt` and `encrypt-file` commands receive
  `-a`, `--add` flag (https://github.com/travis-ci/travis.rb/issues/651)

### 1.8.11 (March 2, 2020)

* Generate unique key-iv pair for each file (https://github.com/travis-ci/travis.rb/pull/678)
* Add logout command

### 1.8.10 (May 5, 2019)

### 1.8.8 (March 3, 2017)

* Fix auto-login for when token is locally available

### 1.8.0 (July 15, 2015)

* Fix listener for pusher changes on [travis-ci.org](https://travis-ci.org).
* Change `monitor` command to only monitor personal repositories if `common` channel is not available.

### 1.7.7 (May 26, 2015)

* Fix `travis whatsup` for fresh Travis Enterprise installations.

### 1.7.6 (April 08, 2015)

* Add support for "received" build state.
* Fix issue with archived logs.
* On version check, do not kill the process if a newer version has been released.

### 1.7.5 (January 15, 2015)

* Add support for url.<remote>.insteadOf
* Fix packaging error with 1.7.4, in which Code Deploy setup code was not included

### 1.7.4 (November 12, 2014)

* Add `travis setup codedeploy`

### 1.7.3 (November 10, 2014)

* Add `travis setup biicode`
* Add `travis env clear`
* Print error message if `travis login` is run for a GitHub account unknown to the Travis CI setup.
* Fix bug in S3 ACL settings.
* Make `travis console` work with newer pry versions.

### 1.7.2 (September 17, 2014)

* Add `travis setup elasticbeanstalk`.
* Properly display educational accounts in `travis accounts`.
* Upgrade go version default for `travis init`.
* Fix SSL verification issue on OS X Yosemite and certain Linux setups.
* Be more forgiving with outdated API version (Enterprise).
* Better handling of multibyte characters in archived logs.
* Use more restrictive permissions for the config file.

### 1.7.1 (August 9, 2014)

* Better error message when trying to encrypt a string that is too long.
* Fix Validation failed error using `travis sshkey --upload`.

### 1.7.0 (August 5, 2014)

* Add `travis encrypt-file`.
* Add `--store-repo`/`-R` to repository commands to permanently store the slug for a repository.
* Announce repository slug when first detected, ask for confirmation in interactive mode.
* Have `travis repos` only print repository slugs in non-interactive mode.
* Add `travis/auto_login` and `travis/pro/auto_login` to the Ruby API for easy authentication.
* Add `--fingerprint` to `pubkey` command.
* Add `fingerprint` to `Repository#public_key`.
* Display better error messages for user errors (user data validation failing, etc).
* Have `travis sshkey --upload` check that the content is a private key.
* Make `travis sshkey --upload` prompt for and remove the pass phrase if the key is encrypted.

### 1.6.17 (July 25, 2014)

* Add `travis sshkey` and corresponding Ruby API.
* Make desktop notifications work on Mac OS X 10.10.

### 1.6.16 (July 19, 2014)

* Fix check for updates.

### 1.6.15 (July 18, 2014)

* Add `travis env [list|add|set|copy]`.
* Add `Repository#env_vars`.
* Add `travis setup ghc`.
* Add `Log#delete_body`, `Job#delete_log` and `Build#delete_logs` to Ruby API.
* Add `--delete`, `--force` and `--no-stream` options to `travis logs`.
* Add `acl` option to `travis setup s3`.
* Add `--set` option to `travis settings`, support non-boolean values.
* Expose `maximum_number_of_builds` setting.
* Give GitHub OAuth token generated by `travis setup releases` a proper description.
* Proper handling for empty or broken config files.
* Reset terminal colors after `travis logs`.

### 1.6.14 (June 17, 2014)

* Add `travis lint` command and Ruby API.

### 1.6.13 (June 15, 2014)

* Added Deis and Hackage setup support.

### 1.6.12 (June 12, 2014)

* Added artifacts setup support.

### 1.6.11 (May 12, 2014)

* Added Cloud 66 and Ninefold setup support.
* Require typhoeus 0.6.8 and later.

### 1.6.10 (April 24, 2014)

* Better CloudFoundry support
* Update Faraday to version 0.9.

### 1.6.9 (April 9, 2014)

* Add `--limit` to `travis requests`.
* Add `--committer` option to `travis history`.
* Avoid error when running `travis login` with a revoked token.
* Add `travis setup releases`.
* Desktop notifications via libnotify are now transient (disappear on their own if the user is active).
* Update Rubinius version generated by `travis init ruby`.
* Improve setup when running `travis` executable that has not been installed via RubyGems.

### 1.6.8 (March 12, 2014)

* Display annotations in `travis show`.
* Add `travis requests` to see build requests Travis CI has received.
* Improve annotation support in the Ruby library.
* Add `Repository#requests` to Ruby library.
* Fix behavior for missing entities.

### 1.6.7 (January 30, 2014)

* Properly display OS for projects tested on multiple operating systems.
* Better error message when using an invalid access token.
* Fix desktop notifications using libnotify (Linux/BSD).
* `travis branches` preserves branch name when displaying Pull Request builds.
* Add `travis setup modulus`.
* Ruby library now supports build annotations.
* Document plugin support.
* Do not have the client raise on unknown API entities.
* Do not try and resolve missing commit data (as it will lead to a 404).

### 1.6.6 (December 16, 2013)

* Fix `travis login --com` for new users.

### 1.6.5 (December 16, 2013)

* Add `travis settings` command for accessing repository settings.
* Add `travis setup opsworks`.
* Add `travis console -x` to run a line of Ruby code with a valid session.
* Add authentication and streaming example for Ruby library.
* Add Ruby API for dealing with repository settings.
* Improve `travis login` and `travis login --auto`. Add ability to load GitHub token from Keychain.
* Only ask for GitHub two-factor auth token if two-factor auth is actually required.
* Fix access right check for `travis caches`.

### 1.6.4 (December 16, 2013)

Release was yanked. See 1.6.5 for changes.

### 1.6.3 (November 27, 2013)

* Fix OS detection on Windows.
* Add `travis repos` command.
* Add `travis setup cloudfiles`.
* Add `travis setup divshot`.
* Add `--date` flag to `travis history`.
* Add upload and target directory options to `travis setup s3`.
* Include commit message in desktop notifications.
* Check if Notification Center or Growl is actually running before sending out notifications.
* Better documentation for desktop notifications.
* Improved handling of pusher errors when streaming.
* Add ability to load archived logs from different host.
* User proper API endpoint for streaming logs, as old endpoint has been removed.
* Make tests run on Rubinius 2.x.

### 1.6.2 (November 8, 2013)

* Remove worker support, as API endpoints have been removed from Travis CI.
* Improve OS detection.
* Fix `travis report`.
* Fix issues with new payload for permissions endpoint (used by `travis monitor`).
* Improve default logic for whether `travis monitor` should display desktop notifications.
* Make desktop notifications work on Mac OSX 10.9.
* Increase and improve debug output.
* Only load pry if console command is actually invoked, not when it is loaded (for instance by `travis help`).

### 1.6.1 (November 4, 2013)

* Update autocompletion when updating travis gem.

### 1.6.0 (November 4, 2013)

* Add `travis cache` to list and delete directory caches.
* Add `travis report` to give a report of the system, endpoint, configuration and last exception.
* Add `Cache` entity.
* Keep `travis monitor` running on API errors.

### 1.5.8 (October 24, 2013)

* Fix bug in completion code that stopped command line client from running.

### 1.5.7 (October 24, 2013)

* Improve logic for automatically figuring out a repository slug based on the tracked git remote.
* Display error if argument passed to `-r` is not a full slug.
* Do not automatically install shell completion on gem installation.
* Add Travis CI mascot as logo to desktop notifications.
* Improve OSX and Growl notifications.
* Require user to be logged in for all commands issued against an enterprise installation.
* Improve error message when not logged in for enterprise installations.
* Fix API endpoint detection for enterprise installations.
* Make streaming API, and thus the `monitor` and `logs` command, work with enterprise installations.
* Add `--build`, `--push` and `--pull` flags to monitor command to allow filtering events.

### 1.5.6 (October 22, 2013)

* Add `travis setup appfog` and `travis setup s3`.
* Use new API for fetching a single branch for Repository#branch. This also circumvents the 25 branches limit.
* Start publishing gem prereleases after successful builds.
* Have `travis logs` display first job for a build if a build number is given (or for the last build if called without arguments)
* Add support for branch names to `travis logs`.
* Add support for just using the job suffix with `travis logs`.
* Improve error message if job cannot be found/identified by `travis logs`.
* Add `travis logout` for removing access token.
* Improve error message for commands that require user to be logged in.
* Add `account` method for fetching a single account to `Travis::Client::Methods`.
* Allow creating account objects for any account, not just these the user is part of. Add `Account#member?` to check for membership.
* Add `Account#repositories` to load all repos for a given account.
* Add `Repository#owner_name` and `Repository#owner` to load the account owning a repository.
* Add `Repository#member?` to check if the current user is a member of a repository.
* Add `Build#pull_request_number` and `Build#pull_request_title`.
* Remove trailing new lines from string passed to `travis encrypt`.
* Fix double `provider` entry generated by `travis setup engineyard`.
* Only load auto-completions if available.
* Fix and improve growl notifications.
* Fix GitHub host detection `travis login --auto`.
* API endpoint may now include a path all the requests will be prefixed with.
* Allow overriding SSL options in Ruby client.
* Add `--insecure` to turn off SSL verification.
* Add `--enterprise`/`-X` option for Travis Enterprise integration.

### 1.5.5 (October 2, 2013)

* Add `travis setup pypi`
* Add `travis setup npm`
* When loading accounts, set all flag to true.
* Fix bug where session.config would be nil instead of a hash.

### 1.5.4 (September 7, 2013)

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

### 1.5.3 (August 22, 2013)

* Fix issues on Windows.
* Improve `travis setup rubygems` (automatically figure out API token for newer RubyGems versions, offer to only release tagged commits, allow changing gem name).
* Add command descriptions to help pages.
* Smarter check if travis gem is outdated.
* Better error messages for non-existing build/job numbers.

### 1.5.2 (August 18, 2013)

* Add `travis cancel`.
* Add `Build#cancel` and `Job#cancel` to Ruby API.
* Add `travis setup cloudfoundry`.
* Add `--set-default` and `--drop-default` to `travis endpoint`.
* Make it possible to configure cli via env variables (`$TRAVIS_TOKEN`, `$TRAVIS_ENDPOINT` and `$TRAVIS_CONFIG_PATH`).
* Improve `travis setup cloudcontrol`.

### 1.5.1 (August 15, 2013)

* Add `travis setup engineyard`.
* Add `travis setup cloudcontrol`.
* Silence warnings when running `travis help` or `travis console`.

### 1.5.0 (August 7, 2013)

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

### 1.4.0 (July 26, 2013)

* Add `travis init`
* Improve install documentation, especially for people from outside the Ruby community
* Improve error message on an expired token
* Add Account entity to library
* Switch to Typhoeus as default HTTP adapter
* Fix tests for forks

### 1.3.1 (July 21, 2013)

* Add `travis whatsup --my-repos`, which corresponds to the "My Repositories" tab in the web interface
* It is now recommended to use Ruby 2.0, any Ruby version prior to 1.9.3 will lead to a warning being displayed. Disable with `--skip-version-check`.
* Add `--override` and `--append` to `travis encrypt`, make default behavior depend on key.
* Add shorthand for `travis encrypt --add`.

### 1.3.0 (July 20, 2013)

* Add `travis setup [heroku|openshift|nodejitsu|sauce_connect]`
* Add `travis branches`
* Add Repository#branch and Repository#branches
* Improve `--help`
* Improve error message when calling `travis logs` with a matrix build number
* Check if travis gem is up to date from time to time (CLI only, not when used as library)

### 1.2.8 (July 19, 2013)

* Make pubkey print out key in ssh encoding, add --pem flag for old format
* Fix more encoding issues
* Fix edge cases that broke history view

### 1.2.7 (July 15, 2013)

* Add pubkey command
* Remove all whitespace from an encrypted string

### v1.2.6 (July 7, 2013)

* Improve output of history command

### v1.2.5 (July 7, 2013)

* Fix encoding issue

### v1.2.4 (July 7, 2013)

* Allow empty commit message

### v1.2.3 (June 27, 2013)

* Fix encoding issue
* Will detect github repo from other remotes besides origin
* Add clear_cache(!) to Travis::Namespace

### v1.2.2 (May 24, 2013)

* Fixed `travis disable`.
* Fix edge cases around `travis encrypt`.

### v1.2.1 (May 24, 2013)

* Builds with high build numbers are properly aligned when running `travis history`.
* Don't lock against a specific backports version, makes it easier to use it as a Ruby library.
* Fix encoding issues.

### v1.2.0 (February 22, 2013)

* add `--adapter` to API endpoints
* added branch to `show`
* fix bug where colors were not used if stdin is a pipe
* make `encrypt` options `--split` and `--add` work together properly
* better handling of missing or empty `.travis.yml` when running `encrypt --add`
* fix broken example code
* no longer require network connection to automatically detect repository slug
* add worker support to the ruby library
* adjust artifacts/logs code to upstream api changes

### v1.1.3 (January 26, 2013)

* use persistent HTTP connections (performance for commands with example api requests)
* include round trip time in debug output

### v1.1.2 (January 24, 2013)

* `token` command
* no longer wrap $stdin in delegator (caused bug on some Linux systems)
* correctly detect when running on Windows, even on JRuby

### v1.1.1 (January 22, 2013)

* Make pry a runtime dependency rather than a development dependency.

### v1.1.0 (January 21, 2013)

* New commands: `console`, `status`, `show`, `logs`, `history`, `restart`, `sync`, `enable`, `disable`, `open` and `whatsup`.
* `--debug` option for all API commands.
* `--split` option for `encrypt`.
* Fix `--add` option for `encrypt` (was naming key `secret` instead of `secure`).
* First class representation for builds, commits and jobs in the Ruby library.
* Print warning when running "encrypt owner/project data", as it's not supported by the new client.
* Improved documentation.

### v1.0.3 (January 15, 2013)

* Fix `-r slug` for repository commands. (#3)

### v1.0.2 (January 14, 2013)

* Only bundle CA certs needed to verify Travis CI and GitHub domains.
* Make tests pass on Windows.

### v1.0.1 (January 14, 2013)

* Improve `encrypt --add` behavior.

### v1.0.0 (January 14, 2013)

* Fist public release.
* Improved documentation.

### v1.0.0pre2  (January 14, 2013)

* Added Windows support.
* Suggestion to run `travis login` will add `--org` if needed.

### v1.0.0pre (January 13, 2013)

* Initial public prerelease.
