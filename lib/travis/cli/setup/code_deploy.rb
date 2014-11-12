require 'travis/cli/setup'
require 'shellwords'

module Travis
  module CLI
    class Setup
      class CodeDeploy < Service
        description "triggering a new deployment on Amazon CodeDeploy"
        AWS_CONFIG = File.expand_path('.aws/config', ENV['HOME'])

        def run
          if File.readable? AWS_CONFIG
            content           = File.read(AWS_CONFIG)
            access_key        = content[/aws_access_key_id = (\S+)\n/,     1]
            secret_access_key = content[/aws_secret_access_key = (\S+)\n/, 1]
          end

          deploy 'codedeploy' do |config|
            config['access_key_id']     = ask("Access key ID: ") { |q| q.default = access_key if access_key }.to_s
            secret_access_key           = nil unless access_key == config['access_key_id']
            config['secret_access_key'] = secret_access_key || ask("Secret access key: ") { |q| q.echo = "*" }.to_s
            config['bucket']            = ask("S3 Bucket: ").to_s
            config['key']               = ask("S3 Key: ").to_s
            config['bundle_type']       = ask("Bundle Type: ") { |q| q.default = config['key'][/\.(zip|tar|tgz)$/, 1] }.to_s
            config['application']       = ask("Application Name: ") { |q| q.default = repository.name }.to_s
            config['deployment_group']  = ask("Deployment Group Name: ").to_s
            encrypt(config, 'secret_access_key') if agree("Encrypt secret access key? ") { |q| q.default = 'yes' }
          end

          if agree("Also push bundle to S3? ")
            cd = travis_config['deploy']
            s3 = {
              'provider'          => 's3',
              'access_key_id'     => cd['access_key_id'],
              'secret_access_key' => cd['secret_access_key'],
              'local_dir'         => 'dpl_cd_upload',
              'skip_cleanup'      => true,
              'on'                => cd['on'],
              'bucket'            => cd['bucket']
            }

            s3['upload_dir']               = File.dirname(cd['key']) if cd['key'].include? '/'
            travis_config['deploy']        = [ s3, cd ]
            upload_file_name               = File.basename(cd['key'])
            source_file                    = ask("Source File: ") { |q| q.default = upload_file_name }
            travis_config['before_deploy'] = [
              "mkdir -p dpl_cd_upload",
              "mv #{Shellwords.escape(source_file)} dpl_cd_upload/#{Shellwords.escape(upload_file_name)}"
            ]
          end
        end
      end
    end
  end
end
