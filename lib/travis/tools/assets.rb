module Travis
  module Tools
    module Assets
      BASE = File.expand_path('../../../../assets', __FILE__)
      extend self

      def asset_path(file)
        File.expand_path(file, BASE).tap do |x|
          raise Travis::Client::FileNotFound, "#{x} does not exist" unless File.exist?(x)
        end
      end

      def asset(file)
        File.read(asset_path(file))
      end

      class << self
        alias [] asset_path
        alias read asset
      end
    end
  end
end
