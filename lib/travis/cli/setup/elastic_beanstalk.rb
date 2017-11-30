require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class ElasticBeanstalk < Service
        description "deployment to AWS Elastic Beanstalk"

        def run
          deploy 'elasticbeanstalk' do |config|
            config['access_key_id'] = ask("Access key ID: ").to_s
            config['secret_access_key'] = ask("Secret access key: ") { |q| q.echo = "*" }.to_s
            config['region'] = ask("Elastic Beanstalk region: ") {|q| q.default = 'us-east-1'}.to_s
            config['app'] = ask("Elastic Beanstalk application name: ").to_s
            config['env'] = ask("Elastic Beanstalk environment to update: ").to_s
            config['bucket_name'] = ask("Bucket name to upload app to: ").to_s

            encrypt(config, 'secret_access_key') if agree("Encrypt secret access key? ") { |q| q.default = 'yes' }
          end
        end
      end
    end
  end
end
