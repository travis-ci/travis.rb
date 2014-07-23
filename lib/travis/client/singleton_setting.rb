require 'json'

module Travis
  module Client
    class SingletonSetting < Entity
      def self.base_path
        "settings/#{one}"
      end

      has :repository

      def repository_id
        id
      end

      def path
        "#{self.class.base_path}/#{id}"
      end

      def update(values = {})
        values = { 'value' => values } unless values.is_a? Hash
        values.each { |key, value| attributes[key.to_s] = value.to_s }
        session.patch_raw(path, JSON.dump(self.class.one => attributes))
        reload
      end

      def delete
        session.delete_raw(path)
        reload
        true
      end

      alias save update
    end
  end
end
