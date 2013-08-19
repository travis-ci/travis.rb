# encoding: utf-8
require 'travis/cli'

module Travis
  module CLI
    class Pubkey < RepoCommand
      description "prints out a repository's public key"
      on('-p', '--[no-]pem', 'encode in format used by pem')

      def run
        say key, "Public key for #{color(repository.slug, :info)}:\n\n%s", :bold
      end

      private

        def key
          key = repository.public_key
          pem? ? key.to_s : key.to_ssh
        end
    end
  end
end
