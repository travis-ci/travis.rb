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
        info "No crons for #{repository.slug}." unless !result['crons'].empty?
        result['crons'].each do | cron |
          display(cron)
        end
      end

      def create(branch, interval, disable_by_build = "false")
        error "Interval must be daily, weekly or monthly. got #{interval}" unless ["daily", "weekly", "monthly"].include? interval
        error "Disable_by_build must be true or false. got #{disable_by_build}" unless ["true", "false"].include? disable_by_build
        result = session.post("v3/repo/#{repository.id}/branch/#{branch}/cron", {interval: interval, disable_by_build: disable_by_build})
        success "Cron with id #{result['cron'].id} created."
      end

      def delete(id)
        result = session.delete("v3/cron/#{id}")
        success "Cron with id #{id} deleted."
      end

      def display(cron)
        say 'ID: ' + cron.id.to_s
        info 'Branch: ' + cron.branch_name
        info 'Interval: ' + cron.interval
        info 'Disable by build: ' + cron.disable_by_build.to_s
        info 'Next Enqueuing: ' + cron.next_enqueuing
      end
    end
  end
end
