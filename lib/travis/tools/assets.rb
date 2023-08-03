# frozen_string_literal: true

require 'pathname'
module Travis
  module Tools
    module Assets
      BASE = File.expand_path('../../../assets', __dir__)

      module_function

      def asset_path(file)
        Pathname.glob(File.expand_path(file, BASE)).tap do |x|
          raise Travis::Client::AssetNotFound, file if x.empty?
        end.first.to_s
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
