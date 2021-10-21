require 'travis/cli'
require 'travis/tools/ssl_key'
require 'travis/tools/github'

module Travis
  module CLI
    class Sshkey < RepoCommand
      description "checks, updates or deletes an SSH key"
      on '-D', '--delete',                  'remove SSH key'
      on '-d', '--description DESCRIPTION', 'set description'
      on '-u', '--upload FILE',             'upload key from given file'
      on '-s', '--stdin',                   'upload key read from stdin'
      on '-c', '--check',                   'set exit code depending on key existing'
      on '-g', '--generate',                'generate SSH key and set up for given GitHub user'
      on '-p', '--passphrase PASSPHRASE',   'pass phrase to decrypt with when using --upload'
      on '-g', '--github-token TOKEN',      'identify by GitHub token'

      def_delegators :repository, :ssh_key

      def run
        error "SSH keys are not available on #{color(session.config['host'], :bold)}" if org?
        delete_key                            if delete?
        update_key File.read(upload), upload  if upload?
        update_key $stdin.read, 'stdin'       if stdin?
        generate_key                          if generate?
        display_key
      end

      def display_key
        say "Current SSH key: #{color(ssh_key.description, :info)}"
        say "Finger print:    #{color(ssh_key.fingerprint, :info)}"
      rescue Travis::Client::NotFound
        say "No custom SSH key installed."
        exit 1 if check?
      end

      def update_key(value, file)
        error "#{file} does not look like a private key" unless value.lines.first =~ /PRIVATE KEY/
        value = remove_passphrase(value)
        self.description ||= ask("Key description: ") { |q| q.default = "Custom Key" } if interactive?
        say "Updating ssh key for #{color slug, :info} with key from #{color file, :info}"
        empty_line
        ssh_key.update(:value => value, :description => description || file)
      end

      def delete_key
        return if interactive? and not danger_zone? "Remove SSH key for #{color slug, :info}?"
        say "Removing ssh key for #{color slug, :info}"
        ssh_key.delete
      rescue Travis::Client::NotFound
        warn "no key found to remove"
      end

      def generate_key
        access_token = nil
        github.with_token do |token|
          access_token = github_auth(token)
        end
        session.access_token = nil
        unless access_token
          raise Travis::Client::GitHubLoginFailed, "all GitHub tokens given were invalid"
        end
        gh = GH.with(token: github_token)
        login = gh['user']['login']
        check_access(gh)
        empty_line

        say "Generating RSA key."
        private_key        = Tools::SSLKey.generate_rsa
        self.description ||= "key for fetching dependencies for #{slug} via #{login}"

        say "Uploading public key to GitHub."
        gh.post("/user/keys", :title => "#{description} (Travis CI)", :key => Tools::SSLKey.rsa_ssh(private_key.public_key))

        say "Uploading private key to Travis CI."
        ssh_key.update(:value => private_key.to_s, :description => description)

        empty_line
        say "You can store the private key to reuse it for other repositories (travis sshkey --upload FILE)."
        if agree("Store private key? ") { |q| q.default = "no" }
          path = ask("Path: ") { |q| q.default = "id_travis_rsa" }
          File.write(path, private_key.to_s)
        end
      end

      def remove_passphrase(value)
        return value unless Tools::SSLKey.has_passphrase? value
        return Tools::SSLKey.remove_passphrase(value, passphrase) || error("wrong pass phrase") if passphrase
        error "Key is encrypted, but missing --passphrase option" unless interactive?
        say "The private key is protected by a pass phrase."
        result = Tools::SSLKey.remove_passphrase(value, ask("Enter pass phrase: ") { |q| q.echo = "*" }) until result
        empty_line
        result
      end

      def check_access(gh)
        gh["repos/#{slug}"]
      rescue GH::Error
        error "GitHub account has no read access to #{color slug, :bold}"
      end

      def github
        @github ||= begin
          load_gh
          Tools::Github.new(session.config['github']) do |g|
            g.note          = "token for fetching dependencies for #{slug} (Travis CI)"
            g.explode       = explode?
            g.github_token  = github_token
            g.login_header  = proc { login_header }
            g.debug         = proc { |log| debug(log) }
            g.after_tokens  = proc { g.explode = true and error("no suitable github token found") }
          end
        end
      end

      def login_header
        say "GitHub deprecated its Authorizations API exchanging a password for a token."
        say "Please visit https://github.blog/2020-07-30-token-authentication-requirements-for-api-and-git-operations for more information."
        say "Try running with #{color("--github-token", :info)} or #{color("--auto-token", :info)} ."
      end
    end
  end
end
