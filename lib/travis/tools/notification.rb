require "travis"
require "travis/tools/system"
require "travis/tools/assets"
require "terminal-notifier"
require "cgi"

module Travis
  module Tools
    module Notification
      extend self
      DEFAULT = [:osx, :growl, :libnotify]
      ICON    = Assets['notification-icon.png']

      def new(*list)
        list.concat(DEFAULT) if list.empty?
        notification = list.map { |n| get(n) }.detect { |n| n.available? }
        raise ArgumentError, "no notification system found (looked for #{list.join(", ")})" unless notification
        notification
      end

      def get(name)
        const = constants.detect { |c| c.to_s[/[^:]+$/].downcase == name.to_s }
        raise ArgumentError, "unknown notifications type %p" % name unless const
        const_get(const).new
      end

      class Dummy
        def notify(title, body)
        end

        def available?
          true
        end
      end

      class OSX
        def notify(title, body)
          TerminalNotifier.notify(body, :title => title)
        end

        def available?
          System.mac? and TerminalNotifier.available?
        end
      end

      class Growl
        def initialize
          @command = "growlnotify"
        end

        def notify(title, body)
          system @command, '-n', 'Travis', '--image', ICON, '-m', body, title
        end

        def available?
          system "which #{@command} >/dev/null 2>/dev/null" unless System.windows?
        end
      end

      class LibNotify < Growl
        def initialize
          @command     = "notify-send"
          @expire_time = 10_000
        end

        def notify(title, body)
          system @command, "--expire-time=#{@expire_time}", "-i", ICON, title, CGI.escapeHTML(body)
        end
      end
    end
  end
end
