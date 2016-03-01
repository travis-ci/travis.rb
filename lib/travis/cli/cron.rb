require 'travis/cli'

module Travis
  module CLI
    class Cron < RepoCommand
      description "show or modify cron jobs"
      subcommands :list, :create, :delete

      def setup
        super
        authenticate
        error "not allowed to access cron jobs for #{color(repository.slug, :bold)}" unless repository.admin?
      end

      def list
        result = session.get("v3/repo/#{repository.id}/crons")
        if result['crons'].empty?
          say "No crons for #{repository.slug}"
        end
        result['crons'].each do | cron |
          display(cron)
        end
      end

      def create(interval)
        result = session.post("v3/repo/#{repository.id}/branch/cron-overview/cron", {interval: "#{interval}"})
        display(result['cron'])
      end

      def delete(id)
        result = session.delete("v3/cron/#{id}")
        say "Cron with id #{id} deleted"
      end

      def display(cron)
        say 'ID: ' + cron.id.to_s
        say 'Branch: ' + cron.branch_name
        say 'Interval: ' + cron.interval
        say 'Disable by build: ' + cron.disable_by_build.to_s
        say 'Next Enqueuing: ' + cron.next_enqueuing
      end
    end
  end
end
