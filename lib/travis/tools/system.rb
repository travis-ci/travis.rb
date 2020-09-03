module Travis
  module Tools
    module System
      extend self

      def recent_version?(version, minimum)
        version = version.split('.').map { |s| s.to_i }
        minimum = minimum.split('.').map { |s| s.to_i }
        (version <=> minimum) >= 0
      end

      def windows?
        File::ALT_SEPARATOR == "\\"
      end

      def mac?
        RUBY_PLATFORM =~ /darwin/i
      end

      def linux?
        RUBY_PLATFORM =~ /linux/i
      end

      def unix?
        not windows?
      end

      def os
        os_name ? "#{os_name} #{os_version}".strip : os_type
      end

      def full_os
        os_name == os_type ? os : "#{os} like #{os_type}"
      end

      def os_version
        @os_version ||= has?(:sw_vers)     && `sw_vers -productVersion`.chomp
        @os_version ||= has?(:lsb_release) && `lsb_release -r -s`.chomp
      end

      def os_name
        @os_name ||= has?(:sw_vers)     && `sw_vers -productName`.chomp
        @os_name ||= has?(:lsb_release) && `lsb_release -i -s`.chomp
      end

      def os_type
        @os_type ||= windows? ? 'Windows' : `uname`.chomp
      end

      def ruby_engine
        defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
      end

      def ruby_version
        "%s-p%s" % [RUBY_VERSION, RUBY_PATCHLEVEL]
      end

      def ruby
        case ruby_engine
        when 'ruby'  then "Ruby #{ruby_version}"
        when 'jruby' then "JRuby #{JRUBY_VERSION} like Ruby #{ruby_version}"
        when 'rbx'   then "Rubinius #{Rubinius.version[/\d\S+/]} like Ruby #{ruby_version}"
        else              "#{ruby_engine} like Ruby #{ruby_version}"
        end
      end

      def rubygems
        return "no RubyGems" unless defined? Gem
        "RubyGems #{Gem::VERSION}"
      end

      def description(*args)
        [ full_os, ruby, rubygems, *args.flatten].compact.uniq.join("; ")
      end

      def has?(command)
        return false unless unix?
        @has ||= {}
        @has.fetch(command) { @has[command] = system "command -v #{command} 2>/dev/null >/dev/null" }
      end

      def running?(app)
        return false unless unix?
        system "/usr/bin/pgrep -u $(whoami) #{app} >/dev/null"
      end
    end
  end
end
