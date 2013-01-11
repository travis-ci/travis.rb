require 'netrc'
require 'yaml'

module Travis
  module Tools
    # This is used when running `travis login --auto`
    class TokenFinder
      attr_accessor :netrc, :hub, :explode, :github

      def self.find(options = {})
        new(options).find
      end

      def initialize(options = {})
        self.netrc   = options[:netrc]  || Netrc.default_path
        self.hub     = options[:hub]    || ENV['HUB_CONFIG'] || '~/.config/hub'
        self.github  = options[:github] || 'github.com'
        self.explode = options[:explode]
      end

      def hub=(file)
        @hub = File.expand_path(file)
      end

      def netrc=(file)
        @netrc = File.expand_path(file)
      end

      def find
        find_netrc || find_hub
      end

      def find_netrc
        return unless File.readable? netrc
        data = Netrc.read(netrc)[github]
        data.detect { |e| e.size == 40 } if data
      rescue => e
        raise e if explode
      end

      def find_hub
        return unless File.readable? hub
        data   = YAML.load_file(File.expand_path(hub))
        data &&= Array(data[github])
        data.first['oauth_token'] if data.size == 1
      rescue => e
        raise e if explode
      end
    end
  end
end
