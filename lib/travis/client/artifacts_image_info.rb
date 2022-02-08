require 'travis/client'

module Travis
  module Client
    class ArtifactsImageInfo < Entity
      preloadable

      attributes :name, :config_content, :description, :image_size
      inspect_info :name

      one  :artifacts_image_info
      many :artifacts_image_infos
    end
  end
end
