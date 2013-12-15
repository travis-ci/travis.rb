require 'travis/pro'
require 'travis/tools/github'
require 'highline/import' # so we can hide the password

# Set up GitHub tool for doing the login handshake.
github = Travis::Tools::Github.new(drop_token: true) do |g|
  g.ask_login    = -> { ask("GitHub login: ") }
  g.ask_password = -> { ask("Password: ") { |q| q.echo = "*" } }
  g.ask_otp      = -> { ask("Two-factor token: ") }
end

# Create temporary GitHub token and use it to authenticate against Travis CI.
github.with_token do |token|
  Travis::Pro.github_auth(token)
end

# Look up the current user.
user = Travis::Pro::User.current
puts "Hello #{user.name}!"

# Display repositories the user is a member of.
repos = Travis::Pro::Repository.find_all(member: user.login)
repos.each { |repo| puts "#{repo.slug} #{repo.last_build_state}" }
