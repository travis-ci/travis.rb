# encoding: utf-8
require 'travis/cli'

module Travis
  module CLI
    class Pubkey < RepoCommand
      attr_accessor :key_format
      description "prints out a repository's public key"
      on('-p', '--pem', 'encode in format used by pem') { |c,_| c.key_format = :pem }
      on('-f', '--fingerprint', 'display fingerprint')  { |c,_| c.key_format = :fingerprint }

      def run
        error "#{key_format} format not supported by #{api_endpoint}" unless key
        say key, "Public key for #{color(repository.slug, :info)}:\n\n%s", :bold
      end

      private

        def key
          key = repository.public_key
          case self.key_format ||= :ssh
          when :fingerprint then key.fingerprint
          when :pem         then key.to_s
          when :ssh         then key.to_ssh
          else raise "unknown format #{key_format}"
          end
        end
    end
  end
end
