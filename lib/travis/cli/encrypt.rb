# encoding: utf-8
require 'travis/cli'

module Travis
  module CLI
    class Encrypt < RepoCommand
      description "encrypts values for the .travis.yml"
      attr_accessor :config_key

      on('-a', '--add [KEY]', 'adds it to .travis.yml under KEY (default: env.global)') do |c, value|
        c.config_key = value || 'env.global'
      end

      on('-s', '--[no-]split', "treat each line as a separate input")
      on('-p', '--append',     "don't override existing values, instead treat as list")
      on('-x', '--override',   "override existing value")

      def run(*args)
        confirm = force_interactive.nil? || force_interactive
        error "cannot combine --override and --append"   if append?   and override?
        error "--append without --add makes no sense"    if append?   and not add?
        error "--override without --add makes no sense"  if override? and not add?
        self.override |= !config_key.start_with?('env.') if add?      and not append?

        if args.first =~ %r{\w+/\w+} && !args.first.include?("=")
          warn "WARNING: The name of the repository is now passed to the command with the -r option:"
          warn "    #{command("encrypt [...] -r #{args.first}")}"
          warn "  If you tried to pass the name of the repository as the first argument, you"
          warn "  probably won't get the results you wanted.\n"
        end

        data = args.join(" ")

        if data.empty?
          say color("Reading from stdin, press Ctrl+D when done", :info) if $stdin.tty?
          data = $stdin.read
        end

        data = split? ? data.split("\n") : [data.strip]
        warn_env_assignments(data)
        encrypted = data.map { |data| repository.encrypt(data) }

        if config_key
          set_config encrypted.map { |e| { 'secure' => e } }
          confirm_and_save_travis_config confirm
        else
          list = encrypted.map { |data| format(data.inspect, "  secure: %s") }
          say(list.join("\n"), template(__FILE__), :none)
        end
      rescue OpenSSL::PKey::RSAError => error
        error "#{error.message.sub(" for key size", "")} - consider using "    <<
          color("travis encrypt-file", [:red, :bold]) <<
          color(" or ", :red)                         <<
          color("travis env set", [:red, :bold])
      end

      private

        def add?
          !!config_key
        end

        def set_config(result)
          parent_config[last_key] = merge_config(result)
        end

        def merge_config(result)
          case subconfig = (parent_config[last_key] unless override?)
          when nil   then result.size == 1 ? result.first : result
          when Array then subconfig + result
          else            result.unshift(subconfig)
          end
        end

        def subconfig
        end

        def key_chain
          @key_chain ||= config_key.split('.')
        end

        def last_key
          key_chain.last
        end

        def parent_config
          @parent_config ||= traverse_config(travis_config, *key_chain[0..-2])
        end

        def traverse_config(hash, key = nil, *rest)
          return hash unless key

          hash[key] = case value = hash[key]
                      when nil  then {}
                      when Hash then value
                      else { 'matrix' => Array(value) }
                      end

          traverse_config(hash[key], *rest)
        end

        def warn_env_assignments(data)
          if /env/.match(config_key) && data.find { |d| /=/.match(d).nil? }
            warn "Environment variables in #{config_key} should be formatted as FOO=bar"
          end
        end
    end
  end
end

__END__
Please add the following to your <[[ color('.travis.yml', :info) ]]> file:

%s

Pro Tip: You can add it automatically by running with <[[ color('--add', :info) ]]>.
