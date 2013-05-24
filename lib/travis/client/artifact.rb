# encoding: utf-8
require 'travis/client'

module Travis
  module Client
    class Artifact < Entity
      # @!parse attr_reader :job_id, :type, :body
      attributes :job_id, :type, :body

      # @!parse attr_reader :job
      has :job

      def encoded_body
        return body unless body.respond_to? :encode
        body.encode 'utf-8'
      end

      def colorized_body
        attributes['colorized_body'] ||= encoded_body.gsub(/[^[:print:]\e\n]/, '')
      end

      def clean_body
        attributes['clean_body'] ||= colorized_body.gsub(/\e[^m]+m/, '')
      end

      one :log
      many :logs
      aka :artifact
    end
  end
end
