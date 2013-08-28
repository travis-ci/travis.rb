require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class Service
        def self.normalized_name(string)
          string.to_s.downcase.gsub(/[^a-z]/, '')
        end

        def self.description(description = nil)
          @description ||= ""
          @description = description if description
          @description
        end

        def self.service_name(service_name = nil)
          @service_name ||= normalized_name(name[/[^:]+$/])
          @service_name = service_name if service_name
          @service_name
        end

        def self.known_as?(name)
          normalized_name(service_name) == normalized_name(name)
        end

        attr_accessor :command

        def initialize(command)
          @command = command
        end

        def method_missing(*args, &block)
          @command.send(*args, &block)
        end
      end
    end
  end
end
