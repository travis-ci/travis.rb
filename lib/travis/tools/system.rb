module Travis
  module Tools
    module System
      extend self

      def windows?
        File::ALT_SEPARATOR == "\\"
      end

      def mac?
        RUBY_PLATFORM =~ /darwin/i
      end

      def linux?
        RUBY_PLATFORM =~ /linux/i
      end

      def os
        @os ||= windows? ? "Windows" : `uname`.chomp
      end

      def full_os
        @full_os ||= mac? ? "#{`sw_vers -productName`.chomp} #{`sw_vers -productVersion`.chomp}" : os
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
        [ os, ruby, rubygems, *args.flatten].compact.uniq.join("; ")
      end
    end
  end
end
