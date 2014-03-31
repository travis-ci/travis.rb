require "travis"
require "travis/tools/system"
require "travis/tools/assets"
require "cgi"

module Travis
  module Tools
    module Notification
      extend self
      DEFAULT = [:osx, :growl, :libnotify]
      ICON    = Assets['notifications/icon.png']

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
        BIN_PATH = Assets['Travis CI.app/Contents/MacOS/Travis CI']
        def notify(title, body)
        end

        def available?
          true
        end
      end

      class OSX
        BIN_PATH = Assets["notifications/Travis CI.app/Contents/MacOS/Travis CI"]

        def notify(title, body)
          system BIN_PATH, '-message', body.to_s, '-title', title.to_s, '-sender', 'org.travis-ci.Travis-CI'
        end

        def available?
          System.mac? and System.os_version.to_s >= '10.8' and System.running? "NotificationCenter"
        end
      end

      class Growl
        def notify(title, body)
          system 'growlnotify', '-n', 'Travis', '--image', ICON, '-m', body, title
        end

        def available?
          System.has? 'growlnotify' and System.running? "Growl"
        end
      end

      class LibNotify
        def notify(title, body)
          system 'notify-send', '--expire-time=10000', '-h', 'int:transient:1', '-i', ICON, title, CGI.escapeHTML(body)
        end

        def available?
          System.has? 'notify-send'
        end
      end
    end
  end
end
