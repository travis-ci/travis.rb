# encoding: utf-8
require 'travis/client'
require 'travis/tools/stream'

module Travis
  module Client
    class Artifact < Entity
      # @!parse attr_reader :job_id, :type, :body
      attributes :job_id, :type, :body
      attr_accessor :stream

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

      def stream_body(data, finished)
        @stream = Travis::Tools::Stream.new
        @stream.on_data data
        @stream.on_finished finished
        @stream.subscribe(job.id)
      end

      one :log
      many :logs
      aka :artifact
    end
  end
end
