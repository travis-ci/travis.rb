require 'travis/cli'

module Travis
  module CLI
    class Tam < ApiCommand
      description "TAM (Travis Artifact Manager) actions"

      on('-c', '--create-image IMAGE_NAME', 'Create image with given name')
      on('-u', '--update-image IMAGE_NAME', 'Update image with given name')
      on('-d', '--delete-image IMAGE_NAME', 'Delete image with given name')

      def run
        error("Please specify an action") if !create_image? && !update_image? && !delete_image?
        error(".travis.lxd.yml file not found in the current directory or is empty") if (create_image? || update_image?) && (!File.exist?('.travis.lxd.yml') || File.read('.travis.lxd.yml').empty?)

        authenticate

        endpoint = if create_image?
                     'v3/artifacts/config/create'
                   elsif update_image?
                     'v3/artifacts/config/update'
                   else
                     # TODO
                   end

        params = JSON.dump(
          image_name: create_image || update_image || delete_image,
          config: File.read('.travis.lxd.yml')
        )
        response = session.post(endpoint, params, 'Content-Type' => 'application/json')

        if create_image?
          say 'Image created'
        elsif update_image?
          say 'Image updated'
        else
          warn 'Image deleted'
        end
      end
    end
  end
end
