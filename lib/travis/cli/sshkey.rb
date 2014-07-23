require 'travis/cli'

module Travis
  module CLI
    class Sshkey < RepoCommand
      description "checks, updates or deletes an SSH key"
      on '-D', '--delete',                  'remove SSH key'
      on '-d', '--description DESCRIPTION', 'set description'
      on '-u', '--upload FILE',             'upload key from given file'
      on '-s', '--stdin',                   'upload key read from stdin'
      on '-c', '--check',                   'set exit code depending on key existing'

      def_delegators :repository, :ssh_key

      def run
        error "SSH keys are not available on #{color(session.config['host'], :bold)}" if org?
        delete_key if delete?
        update_key File.read(upload), upload  if upload?
        update_key $stdin.read, 'stdin'       if stdin?
        display_key
      end

      def display_key
        say "Current SSH key: #{color(ssh_key.description, :info)}"
      rescue Travis::Client::NotFound
        say "No custom SSH key installed."
        exit 1 if check?
      end

      def update_key(value, file)
        self.description ||= ask("Key description: ") { |q| q.default = file } if interactive?
        say "updating ssh key for #{color slug, :info} with key from #{color file, :info}"
        ssh_key.update(value: value, description: description || file)
      end

      def delete_key
        return if interactive? and not danger_zone? "Remove SSH key for #{color slug, :info}?"
        say "removing ssh key for #{color slug, :info}"
        ssh_key.delete
      rescue Travis::Client::NotFound
        warn "no key found to remove"
      end
    end
  end
end
