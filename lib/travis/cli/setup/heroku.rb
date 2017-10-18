require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Heroku < Service
        description "automatic deployment to Heroku"

        def run
          deploy 'heroku' do |config|
            config['api_key'] = get_token
            config['api_key'] = ask("Heroku API token: ") { |q| q.echo = "*" }.to_s if config['api_key'].to_s.empty?
            config['app']     = `heroku apps:info 2>/dev/null`.scan(/^=== (.+)$/).flatten.first
            config['app']     = ask("Heroku application name: ") { |q| q.default = repository.name }.to_s if config['app'].nil?
          end
        end

        def get_token
          return unless Tools::System.has? 'heroku'
          say "Generating Heroku token - "
          system "heroku auth:whoami"
          unless debug_run 'heroku authorizations'
            say "Installing Heroku OAuth plugin"
            debug_run 'heroku plugins:install https://github.com/heroku/heroku-oauth'
          end
          `heroku authorizations:create --description "Travis CI (#{repository.slug})"`[/Token:\s+(\S+)/, 1]
        end

        def debug_run(cmd)
          command.debug "$ #{cmd}"
          IO.popen(cmd, :err=>[:child, :out]) do |io|
            command.debug("> #{io.gets.sub(/(\S)\s*\n|\n/, '\1')}") until io.eof?
          end
          result = $?.success?
          command.debug "#{cmd} - #{result ? "succeeded" : "failed"}"
          result
        end
      end
    end
  end
end