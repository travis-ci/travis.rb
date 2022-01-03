require 'travis/tools/system'
require 'yaml'
require 'json'
require 'gh'

module Travis
  module Tools
    class Github
      TOKEN_SIZE  = 40
      GITHUB_API  = 'api.github.com'
      GITHUB_HOST = 'github.com'

      attr_accessor :api_url, :scopes, :github_token, :drop_token, :callback, :explode, :after_tokens,
        :login_header, :auto_token, :note,
        :hub_path, :oauth_paths, :composer_path, :git_config_keys, :debug, :no_token, :check_token

      def initialize(options = nil)
        @check_token     = true
        @ask_login       = proc { raise "ask_login callback not set" }
        @after_tokens    = proc { }
        @debug           = proc { |_| }
        @hub_path        = ENV['HUB_CONFIG'] || '~/.config/hub'
        @oauth_paths     = ['~/.github-oauth-token']
        @composer_path   = "~/.composer/config.json"
        @note            = 'temporary token'
        @git_config_keys = %w[github.token github.oauth-token]
        @scopes          = ['user', 'user:email', 'repo'] # overridden by value from /config
        options.each_pair { |k,v| send("#{k}=", v) if respond_to? "#{k}=" } if options
        yield self if block_given?
      end

      def with_token
        each_token { |t| break yield(t) }
      end

      def each_token
        require 'gh' unless defined? GH
        possible_tokens { |t| yield(t) if acceptable?(t) }
      ensure
        callback, self.callback = self.callback, nil
        callback.call if callback
      end

      def with_session(&block)
        with_token { |t| GH.with(:token => t) { yield(t) } }
      end

      def possible_tokens(&block)
        return block[github_token] if github_token

        if auto_token
          git_tokens(&block)
          hub_tokens(&block)
          oauth_file_tokens(&block)
          github_for_mac_token(&block)
          issuepost_token(&block)
          composer_token(&block)
        end

        if github_token || auto_token
          after_tokens.call
        elsif login_header
          login_header.call
        end
      end

      def git_tokens
        return unless System.has? 'git'
        git_config_keys.each do |key|
          `git config --get-all #{key}`.each_line do |line|
            token = line.strip
            yield token unless token.empty?
          end
        end
      end

      def composer_token
        file(composer_path) do |content|
          token = JSON.parse(content)['config'].fetch('github-oauth', {})[host]
          yield token if token
        end
      end

      def hub_tokens
        hub.fetch(host, []).each do |entry|
          yield entry["oauth_token"] if entry["oauth_token"]
        end
      end

      def oauth_file_tokens(&block)
        oauth_paths.each do |path|
          file(path) do |content|
            token = content.strip
            yield token unless token.empty?
          end
        end
      end

      def hub
        file(hub_path, {}) do |contents|
          YAML.load(contents)
        end
      end

      def issuepost_token(&block)
        security(:generic, :w, "-l issuepost.github.access_token",  "issuepost token", &block) if host == 'github.com'
      end

      def github_for_mac_token(&block)
        command = '-s "github.com/mac"'
        security(:internet, :w, command, "GitHub for Mac token", &block) if host == 'github.com'
      end

      def host
        api_host == GITHUB_API ? GITHUB_HOST : api_host
      end

      def api_host
        return GITHUB_API unless api_url
        api_url[%r{^(?:https?://)?([^/]+)}, 1]
      end

      def acceptable?(token)
        return true unless check_token
        gh   = GH.with(:token => token)
        user = gh['user']

        true
      rescue GH::Error => error
        debug "token is not acceptable: #{gh_error(error)}"
        false
      end

      private

        def gh_error(error)
          raise error if explode
          if error.info.key? :response_body
            JSON.parse(error.info[:response_body])["message"].to_s
          else
            "Unknown error"
          end
        end

        def debug(line)
          return unless @debug
          @debug.call "Tools::Github: #{line}"
        end

        def security(type, key, arg, name)
          return false unless System.has? 'security'
          return false unless system "security find-#{type}-password #{arg} 2>/dev/null >/dev/null"
          debug "requesting to load #{name} from keychain"
          result = %x[security find-#{type}-password #{arg} -#{key} 2>&1].chomp
          $?.success? ? yield(result) : debug("request denied")
        rescue => e
          raise e if explode
        end

        def file(path, default = nil)
          path        &&= File.expand_path(path)
          @file       ||= {}
          @file[path] ||= if path and File.readable?(path)
            debug "reading #{path}"
            yield File.read(path)
          end
          @file[path] || default
        rescue => e
          raise e if explode
        end
    end
  end
end
