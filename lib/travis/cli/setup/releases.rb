require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Releases < Service
        description "Upload Assets to GitHub Releases"

        def run
          deploy 'releases' do |config|
            config['api_key'] = ask("GitHub Oauth Key(With repo or repo:public permission): ") { |q| q.echo = "*" }.to_s
            config['file'] = ask("File to Upload: ").to_s
          end
        end
      end
    end
  end
end