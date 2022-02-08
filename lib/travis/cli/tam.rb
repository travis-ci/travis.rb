require 'travis/cli'

module Travis
  module CLI
    class Tam < ApiCommand
      description 'TAM (Travis Artifact Manager) actions'

      on('-c', '--create-image', 'Create an image from .travis.lxd.yml')
      on('-u', '--update-image', 'Update the image based on .travis.lxd.yml')
      on('-d', '--delete-image IMAGE_NAME', 'Delete the image with the given name')
      on('-i', '--image-info IMAGE_NAME', 'Get info about the image')
      on('-l', '--logs IMAGE_NAME', 'Get the latest build log for the image')
      on('-s', '--build-status IMAGE_NAME', 'Get the latest build status for the image')

      def run
        error('Please specify an action') if !create_image? && !update_image? && !delete_image? && !image_info? && !logs? && !build_status?
        error('.travis.lxd.yml file not found in the current directory or is empty') if (create_image? || update_image?) && (!File.exist?('.travis.lxd.yml') || File.read('.travis.lxd.yml').empty?)

        authenticate

        endpoint = if create_image?
                     'v3/artifacts/config/create'
                   elsif update_image?
                     'v3/artifacts/config/update'
                   elsif delete_image?
                     "v3/artifacts/#{CGI.escape(delete_image)}"
                   elsif image_info?
                     "v3/artifacts/#{CGI.escape(image_info)}/info"
                   elsif logs?
                     "v3/artifacts/#{CGI.escape(logs)}/logs"
                   else
                     "v3/artifacts/#{CGI.escape(build_status)}/build_status"
                   end

        if delete_image?
          session.delete_raw(endpoint)
        elsif create_image? || update_image?
          params = {
            config: File.read('.travis.lxd.yml')
          }

          begin
            response = session.post_raw(endpoint, JSON.dump(params), 'Content-Type' => 'application/json')
            unless response['warnings'].nil?
              warn color('Following warnings were generated:', [:bold, 'yellow'])
              response['warnings'].each { |warning| warn color(warning, 'yellow') }
            end
          rescue Travis::Client::ValidationFailed => e
            error e.message
            return
          end
        else
          data = nil
          begin
            data = session.get_raw(endpoint)
          rescue Travis::Client::ValidationFailed => e
            error 'Failed to fetch build status'
            return
          end
          if image_info?
            image_information = Travis::Client::ArtifactsImageInfo.new(session, 0)
            image_information.update_attributes(data)
          end
        end

        if create_image?
          say 'Image created'
          return
        end

        if update_image?
          say 'Image updated'
          return
        end

        if delete_image?
          warn 'Image deleted!'
          return
        end

        if image_info?
          say "Name: #{image_information.name}"
          say "Size: #{(image_information.image_size.to_f / 1024**2).round(2)}MB"
          say "Description: #{image_information.description.presence || '<no description>'}"
          return
        end

        if logs?
          say data['log']
          return
        end

        if build_status?
          say data['status']

          return
        end
      end
    end
  end
end
