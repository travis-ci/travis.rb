require 'travis/cli'

module Travis
  module CLI
    class Settings < RepoCommand
      attr_accessor :setting

      description "access repository settings"
      on('--keys', 'always use setting key instead of description')
      on('-t', '--enable',  'enable boolean setting(s)')  { |c  | c.setting = true  }
      on('-f', '--disable', 'disable boolean setting(s)') { |c  | c.setting = false }
      on('-s', '--set VALUE', 'set to given value')       { |c,v| c.setting = v     }
      on('-c', '--configure', 'change settings interactively')

      DESCRIPTIONS = {
        :builds_only_with_travis_yml => "Only run builds with a .travis.yml",
        :build_pushes                => "Build pushes",
        :build_pull_requests         => "Build pull requests",
        :maximum_number_of_builds    => "Maximum number of concurrent builds",
        :auto_cancel_pushes          => "Cancel older push builds that are not yet running",
        :auto_cancel_pull_requests   => "Cancel older pull request builds that are not yet running"
      }

      def run(*keys)
        exit 1 if interactive? and keys.empty? and !setting.nil? and !all_settings? and !configure?
        authenticate
        say repository.slug, "Settings for %s:"
        repository.settings.to_h.each do |key, value|
          next unless keys.empty? or keys.include? key
          if configure?
            if boolean? key
              repository.settings[key] = agree("#{describe(key, "enable #{key}")}? ") do |q|
                default   = setting.nil? ? value : setting
                q.default = default ? "yes" : "no"
              end
            else
              repository.settings[key] = ask("#{describe(key,  "Value for #{key}")}: ", Integer) do |q|
                default   = setting.to_i if setting and setting.respond_to? :to_i
                default ||= value
                default ||= 0
                q.default = default
              end
            end
          else
            value  = repository.settings[key] = setting unless setting.nil?
            descr  = color(describe(key, color(key, :info)) { |s| key.ljust(30) + " " + color(s, [:reset, :bold]) }, :info)
            say format_value(value) << " " << descr
          end
        end
        repository.settings.save if configure? or !setting.nil?
      end

      def boolean?(key)
        key.to_sym != :maximum_number_of_builds
      end

      def format_value(value)
        case value
        when false, nil then color("[-]", [ :bold, :red   ])
        when true       then color("[+]", [ :bold, :green ])
        else color(value.to_s.rjust(3),    [ :bold, :blue  ])
        end
      end

      def all_settings?
        agree("Really #{setting ? "enable" : "disable"} all settings? ") do |q|
          q.default = "no"
        end
      end

      def describe(key, description = key)
        return description if keys?
        desc = DESCRIPTIONS[key.to_sym]
        desc &&= yield(desc) if block_given?
        desc || description
      end
    end
  end
end
