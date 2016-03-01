require 'travis/client'

module Travis
  module Client
    class Cron < Entity
      preloadable

      attributes :interval, :disable_by_build, :next_enqueuing, :branch_name, :repository_id

      has :repository

      one :cron
      many :crons

      def update_attributes(data)
        data.each_pair do |key, value|
          if key == 'repository'
            key = :repository_id
            value = value['id']
          end
          if key == 'branch'
            key = :branch_name
            value = value['name']
          end
          self[key] = value
        end
      end

      def missing?(key)
        false
      end
    end
  end
end
