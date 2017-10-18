require 'travis/cli'
require 'travis/tools/system'

module Travis
  module CLI
    class Report < ApiCommand
      description "generates a report useful for filing issues"
      on '-r', '--known-repos', 'include repositories in report'
      skip :authenticate, :clear_error

      def run
        display("System",    :general)
        display("CLI",       :cli_info)
        display("Session",   :session_info)
        display("Endpoints", :endpoints)
        display("Known Repositories", :known_repos) if known_repos?
        display_error
        say "For issues with the command line tool, please visit #{color("https://github.com/travis-ci/travis.rb/issues", :underline)}."
        say "For Travis CI in general, go to #{color("https://github.com/travis-ci/travis-ci/issues", :underline)} or email #{color("support@travis-ci.com", :underline)}."
      end

      def display_error
        return unless error = load_file("error.log")
        display("Last Exception", :say, color(error, :info))
      end

      def display(title, method, *args)
        say color(title, [:bold, :underline])
        send(method, *args) { |*a| list(*a) }
        puts
      end

      def list(key, value, additional = nil)
        value = case value
                when Array then value.empty? ? 'none' : value.map(&:inspect).join(", ")
                when true  then "yes"
                when false then "no"
                when nil   then "unknown"
                else value.to_s
                end
        additional &&= " (#{additional})"
        say "#{key}:".ljust(known_repos? ? 50 : 25) << " " << color(value.to_s, :bold) << additional.to_s
      end

      def general
        yield "Ruby",               Tools::System.ruby
        yield "Operating System",   Tools::System.os
        yield "RubyGems",           Tools::System.rubygems
      end

      def cli_info
        yield "Version",            Travis::VERSION
        yield "Plugins",            defined?(TRAVIS_PLUGINS) ? TRAVIS_PLUGINS : []
        yield "Auto-Completion",    Tools::Completion.completion_installed?
        yield "Last Version Check", last_check['at'] ? Time.at(last_check['at']) : 'never'
      end

      def session_info
        yield "API Endpoint",       api_endpoint
        yield "Logged In",          user_info
        yield "Verify SSL",         !insecure
        yield "Enterprise",         enterprise?
      end

      def endpoints
        config['endpoints'].each do |endpoint, info|
          info = [
            info['access_token']         ? 'access token' : nil,
            info['insecure']             ? 'insecure'     : nil,
            default_endpoint == endpoint ? 'default'      : nil,
            endpoint == api_endpoint     ? 'current'      : nil
          ].compact
          yield endpoint_name(endpoint), endpoint, info.join(', ')
        end
      end

      def endpoint_name(url, prefix = "")
        case url
        when Travis::Client::ORG_URI  then "#{prefix}org"
        when Travis::Client::PRO_URI  then "#{prefix}pro"
        when /api-staging\.travis-ci/ then endpoint_name(url.sub("api-staging.", "api."), "staging-")
        else
          key, _ = config['enterprise'].detect { |k,v| v.start_with? url } if config['enterprise'].respond_to?(:detect)
          key ? "enterprise %p" % key : "???"
        end
      end

      def known_repos
        config["repos"].each do |key, info|
          yield key, info['endpoint']
        end
      end

      def user_info
        access_token ? "as %p" % user.login : "no"
      rescue Travis::Client::Error => e
        e.message
      end
    end
  end
end
