require 'travis/cli'

module Travis
  module CLI
    class Settings < RepoCommand
      attr_accessor :setting

      description "access repository settings"
      on('--keys', 'always use setting key instead of description')
      on('-t', '--enable',  'enable the setting(s)')  { |c| c.setting = true  }
      on('-f', '--disable', 'disable the setting(s)') { |c| c.setting = false }
      on('-c', '--configure', 'change settings interactively')

      DESCRIPTIONS = {
        :builds_only_with_travis_yml => "Only run builds with a .travis.yml",
        :build_pushes                => "Build pushes",
        :build_pull_requests         => "Build pull requests"
      }

      def run(*keys)
        exit 1 if interactive? and keys.empty? and !setting.nil? and !all_settings? and !configure?
        authenticate
        say repository.slug, "Settings for %s:"
        repository.settings.to_h.each do |key, value|
          next unless keys.empty? or keys.include? key
          if configure?
            repository.settings[key] = agree("#{describe(key, "enable #{key}")}? ") do |q|
              default   = setting.nil? ? value : setting
              q.default = default ? "yes" : "no"
            end
          else
            value = repository.settings[key] = setting unless setting.nil?
            descr = color(describe(key, color(key, :info)) { |s| key.ljust(30) + " " + color(s, [:reset, :bold]) }, :info)
            say color("[#{value ? "+" : "-"}] ", [:bold, value ? :green : :red]) << descr
          end
        end
        repository.settings.save if configure? or !setting.nil?
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
