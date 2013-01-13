require 'travis/client'

module Travis
  module Client
    class Repository < Entity
      attributes :slug, :description, :last_build_id, :last_build_number, :last_build_state, :last_build_duration, :last_build_language, :last_build_started_at, :last_build_finished_at
      inspect_info :slug

      one  :repo
      many :repos

      def last_build_started_at=(time)
        set_attribute(:last_build_started_at, time(time))
      end

      def last_build_finished_at=(time)
        set_attribute(:last_build_finished_at, time(time))
      end
    end
  end
end
