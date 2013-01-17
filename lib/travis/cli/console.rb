require 'travis/cli'
require 'pry'

module Travis
  module CLI
    class Console < ApiCommand
      def run
        Object.send(:include, Client::Namespace.new(session))
        binding.pry(:quiet => true, :prompt => Pry::SIMPLE_PROMPT)
      end
    end
  end
end
