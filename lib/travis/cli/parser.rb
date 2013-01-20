require 'travis/cli'
require 'optparse'

module Travis
  module CLI
    module Parser
      def on_initialize(&block)
        @on_initialize ||= []
        @on_initialize << block if block
        if superclass.respond_to? :on_initialize
          superclass.on_initialize + @on_initialize
        else
          @on_initialize
        end
      end

      def on(*args, &block)
        block ||= begin
          full_arg = args.detect { |a| a.start_with? '--' }
          name = full_arg.gsub(/^--(\[no-\])?(\S+).*$/, '\2').gsub('-', '_')
          attr_reader(name)               unless method_defined? name
          attr_writer(name)               unless method_defined? "#{name}="
          alias_method("#{name}?", name)  unless method_defined? "#{name}?"
          proc { |instance, value| instance.public_send("#{name}=", value) }
        end

        on_initialize do |instance|
          instance.parser.on(*args) do |value|
            block.call(instance, value)
          end
        end
      end

      def new(*)
        attr_accessor :parser unless method_defined? :parser
        result        = super
        result.parser = OptionParser.new
        on_initialize.each { |b| b[result] }
        result
      end
    end
  end
end
