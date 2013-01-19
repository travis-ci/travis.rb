require 'travis/client'

module Travis
  module Client
    class Artifact < Entity
      # @!parse attr_reader :id, :job_id, :type, :body
      attributes :id, :job_id, :type, :body

      # @!parse attr_reader :job
      has :job

      def colorized_body
        attributes['colorized_body'] ||= body.gsub(/[^[:print:]\e\n]/, '')
      end

      def clean_body
        attributes['clean_body'] ||= colorized_body.gsub(/\e[^m]+m/, '')
      end

      one :artifact
      many :artifacts
      aka :log
    end
  end
end
