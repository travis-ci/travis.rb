require 'travis/cli'
require 'shellwords'

module Travis
  module CLI
    class Env < RepoCommand
      on('-P', '--[no-]public',   'make new values public')
      on('-p', '--[no-]private',  'make new values private') { |c,v| c.public = !v }
      on('-u', '--[no-]unescape', 'do not escape values')
      on('-f', '--force',         'do not ask for confirmation when clearing out all variables')

      description "show or modify build environment variables"
      subcommands :list, :set, :unset, :copy, :clear

      def setup
        super
        authenticate
        error "not allowed to access environment variables for #{color(repository.slug, :bold)}" unless repository.admin?
      end

      def set(name, value)
        options ||= { :public => public } if public != nil
        say color('[+] ', [:green, :bold]) + "setting environment variable #{color "$#{name}", :info}"
        value = Shellwords.escape(value) unless unescape?
        env_vars.upsert(name, value, options || {})
      end

      def copy(*names)
        names.each do |name|
          if ENV.include? name
            set(name, ENV[name])
          else
            warn "missing in current environment: #{color "$#{name}", :bold}"
          end
        end
      end

      def unset(*names)
        remove_vars { |var| names.include? var.name }
      end

      def clear
        exit   if env_vars.empty?
        exit 1 if interactive? and not force? and not danger_zone? "Clear out all env variables for #{color(repository.slug, :bold)}?"
        remove_vars
      end

      def remove_vars
        env_vars.each do |var|
          next if block_given? and not yield(var)
          say color('[x] ', [:red, :bold]) + "removing environment variable #{color "$#{var.name}", :info}"
          var.delete
        end
      end

      def list
        say color("# environment variables for #{color repository.slug, :bold}", :info)
        env_vars.each { |v| say "#{v.name}=" << color(v.value || "[secure]", :bold) }
      end

      def env_vars
        repository.env_vars
      end
    end
  end
end