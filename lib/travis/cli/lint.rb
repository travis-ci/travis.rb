require 'travis/cli'
require 'yaml'

module Travis
  module CLI
    class Lint < ApiCommand
      description 'display warnings for a .travis.yml'
      on '-q', '--[no-]quiet',     'does not print anything'
      on '-x', '--[no-]exit-code', 'sets the exit code to 1 if there are warning'

      def run(file = nil)
        file ||= '.travis.yml' if $stdin.tty? or $stdin.eof?

        if file and file != '-'
          debug "reading #{file}"
          error "file does not exist: #{color(file, :bold)}" unless File.exist? file
          error "cannot read #{color(file, :bold)}"          unless File.readable? file
          content = File.read(file)
        else
          debug "reading stdin"
          file    = 'STDIN'
          content = $stdin.read
        end

        begin
          YAML.load(content)
        rescue Psych::SyntaxError => e
          error "#{file} is not valid YAML: #{e.message}"
        end

        lint = session.lint(content)

        unless quiet?
          if lint.ok?
            say "valid", color("Hooray, #{file} looks %s :)", :success)
          else
            say "Warnings for #{color(file, :info)}:"
            lint.warnings.each do |warning|
              say color('[x]', [:red, :bold]) + " "
              if warning.key.any?
                say [
                  color('in ', :info),
                  color(warning.key.join('.'), [:info, :bold, :underline]),
                  color(' section:', :info), ' '
                ].join
              end
              say warning.message.gsub(/"(.*?)"/) { color($1, [:info, :important]) }
            end
          end
        end

        exit 1 if lint.warnings? and exit_code?
      end
    end
  end
end
