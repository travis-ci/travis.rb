# encoding: utf-8
require 'travis/cli'
require 'travis/tools/system'

require 'securerandom'
require 'openssl'
require 'digest'
require 'shellwords'

module Travis
  module CLI
    class EncryptFile < RepoCommand
      attr_accessor :stage
      description 'encrypts a file and adds decryption steps to .travis.yml'
      on '-K', '--key KEY', 'encryption key to be used (randomly generated otherwise)'
      on '--iv IV', 'encryption IV to be used (randomly generated otherwise)'
      on '-d', '--decrypt', 'decrypt the file instead of encrypting it, requires key and iv'
      on '-f', '--force', 'override output file if it exists'
      on '-p', '--print-key', 'print (possibly generated) key and iv'
      on '-w', '--decrypt-to PATH', 'where to write the decrypted file to on the Travis CI VM'
      on '-a', '--add [STAGE]', 'automatically add command to .travis.yml (default stage is before_install)' do |c, stage|
        c.stage = stage || 'before_install'
      end

      def run(input_path, output_path = nil)
        confirm = force_interactive.nil? || force_interactive

        self.decrypt_to ||= decrypt_to_for(input_path)
        output_path     ||= File.basename(output_path_for(input_path))
        self.output       = $stdout.tty? ? StringIO.new : $stderr if output_path == '-'
        result            = transcode(input_path)

        if output_path == '-'
          $stdout.puts result
        else
          say "storing result as #{color(output_path, :info)}"
          write_file(output_path, result, force)
          return if decrypt?

          error "requires --decrypt-to option when reading from stdin" unless decrypt_to?

          set_env_vars(input_path)

          command = decrypt_command(output_path)
          stage ? store_command(command, confirm) : print_command(command)

          notes(input_path, output_path)
        end
      end

      def setup
        super
        self.key        ||= SecureRandom.hex(32) unless decrypt?
        self.iv         ||= SecureRandom.hex(16) unless decrypt?
        error "key must be 64 characters long and a valid hex number" unless key =~ /^[a-f0-9]{64}$/
        error "iv must be 32 characters long and a valid hex number"  unless iv  =~ /^[a-f0-9]{32}$/
      end

      def print_command(command)
        empty_line
        say command, template(__FILE__)
      end

      def store_command(command, confirm)
        travis_config[stage] = Array(travis_config[stage])
        travis_config[stage].delete(command)
        travis_config[stage].unshift(command)
        confirm_and_save_travis_config confirm
      end

      def decrypt_command(path)
        "openssl aes-256-cbc -K $#{env_name(path, :key)} -iv $#{env_name(path, :iv)} -in #{escape_path(path)} -out #{escape_path(decrypt_to)} -d"
      end

      def set_env_vars(input_path)
        say "storing secure env variables for decryption"
        repository.env_vars.upsert env_name(input_path, :key), key, :public => false
        repository.env_vars.upsert env_name(input_path, :iv),  iv,  :public => false
      end

      def env_name(input_path, name)
        @env_prefix ||= "encrypted_#{Digest.hexencode(Digest::SHA1.digest(input_path)[0..5])}"
        "#{@env_prefix}_#{name}"
      end

      def notes(input_path, output_path)
        say "\nkey: #{color(key, :info)}\niv:  #{color(iv,  :info)}" if print_key?
        empty_line
        say "Make sure to add #{color(output_path, :info)} to the git repository."
        say "Make sure #{color("not", :underline)} to add #{color(input_path, :info)} to the git repository." if input_path != '-'
        say "Commit all changes to your #{color('.travis.yml', :info)}."
      end

      def transcode(input_path)
        description = "stdin#{' (waiting for input)' if $stdin.tty?}" if input_path == '-'
        say "#{decrypt ? "de" : "en"}crypting #{color(description || input_path, :info)} for #{color(slug, :info)}"

        data     = input_path == '-' ? $stdin.read : File.binread(input_path)
        aes      = OpenSSL::Cipher.new('AES-256-CBC')
        decrypt  ? aes.decrypt : aes.encrypt
        aes.key  = [key].pack('H*')
        aes.iv   = [iv].pack('H*')

        aes.update(data) + aes.final
      end

      def decrypt_to_for(input_path)
        return if input_path == '-'
        if input_path.start_with? Dir.home
          input_path.sub(Dir.home, '~')
        else
          input_path
        end
      end

      def escape_path(path)
        Shellwords.escape(path).sub(/^\\~\//, '~\/')
      end

      def output_path_for(input_path)
        case input_path
        when '-'           then return '-'
        when /^(.+)\.enc$/ then return $1 if     decrypt?
        when /^(.+)\.dec$/ then return $1 unless decrypt?
        end

        if interactive? and input_path =~ /(\.enc|\.dec)$/
          exit 1 unless danger_zone? "File extension of input file is #{color($1, :info)}, are you sure that is correct?"
        end

        "#{input_path}.#{decrypt ? 'dec' : 'enc'}"
      end
    end
  end
end

__END__
Please add the following to your build script (<[[ color('before_install', :info) ]]> stage in your <[[ color('.travis.yml', :info) ]]>, for instance):

    %s

Pro Tip: You can add it automatically by running with <[[ color('--add', :info) ]]>.
