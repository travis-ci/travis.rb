module Travis
  module Tools
    module Assets
      BASE = File.expand_path('../../../../assets', __FILE__)
      extend self

      def asset_path(file)
        File.expand_path(file, BASE)
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