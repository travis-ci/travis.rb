require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class GCS < Service
        description "automatic pushing to Google Cloud Storage"

        def run
          deploy 'gcs' do |config|
            config['access_key_id'] = ask("Access key ID: ").to_s
            config['secret_access_key'] = ask("Secret access key: ") { |q| q.echo = "*" }.to_s
            config['bucket'] = ask("Bucket: ").to_s
            local_dir = ask("Local project directory to upload (Optional): ").to_s
            config['local-dir'] = local_dir unless local_dir.empty?
            encrypt(config, 'secret_access_key') if agree("Encrypt secret access key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end