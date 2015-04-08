# encoding: utf-8
require 'travis/client'
require 'travis/tools/safe_string'

module Travis
  module Client
    class Artifact < Entity
      CHUNKED = "application/json; chunked=true; version=2, application/json; version=2"
      TEXT    = "#{CHUNKED}, text/plain"

      # @!parse attr_reader :job_id, :type, :body
      attributes :job_id, :type, :body

      # @!parse attr_reader :job
      has :job

      def delete_body(reason = {})
        reason = { :reason => reason } unless reason.is_a? Hash
        session.patch_raw("jobs/#{job_id}/log", reason)
        reload
      rescue Travis::Client::Error => error
        raise unless error.message == '409'
        self
      end

      def encoded_body
        Tools::SafeString.encoded(body)
      end

      def colorized_body
        attributes['colorized_body'] ||= Tools::SafeString.colorized(body)
      end

      def clean_body
        attributes['clean_body'] ||= Tools::SafeString.clean(body)
      end

      def current_body
        attributes['current_body'] ||= begin
          body = load_attribute('body')
          if body.to_s.empty?
            log  = session.get_raw("jobs/#{job_id}/log", nil, "Accept" => TEXT)
            body = String === log ? log : log['log']['body']
          end
          body
        end
      end

      def body(stream = block_given?)
        return current_body unless block_given? or stream
        return yield(current_body) unless stream and job.pending?
        number = 0

        session.listen(self) do |listener|
          listener.on 'job:log' do |event|
            next unless event.payload['number'] > number
            number = event.payload['number']
            yield event.payload['_log']
            listener.disconnect if event.payload['final']
          end

          listener.on 'job:finished' do |event|
            listener.disconnect
          end

          listener.on_connect do
            data = session.get_raw("/logs/#{id}", nil, "Accept" => CHUNKED)['log']
            if data['parts']
              data['parts'].each { |p| yield p['content'] }
              number = data['parts'].last['number'] if data['parts'].any?
            else
              yield data['body']
              listener.disconnect
            end
          end
        end
      end

      def pusher_entity
        job
      end

      one :log
      many :logs
      aka :artifact
    end
  end
end
