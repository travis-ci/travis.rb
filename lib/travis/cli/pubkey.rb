# encoding: utf-8
require 'travis/cli'

module Travis
  module CLI
    class Pubkey < RepoCommand
      def run
        say key, "Public key for #{color(repository.slug, :info)}:\n\n%s", :bold
      end

      private

        def key
          repository.public_key.to_s
        end
    end
  end
end
