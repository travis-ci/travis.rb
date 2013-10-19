require 'travis/cli'

module Travis
  module CLI
    class Show < RepoCommand
      description "displays a build or job"

      def run(number = last_build.number)
        number = repository.branch(number).number if number !~ /^\d+(\.\d+)?$/ and repository.branch(number)
        entity = job(number) || build(number)

        error "could not find job or build #{repository.slug}##{number}" unless entity

        say template(__FILE__) % [
          entity.class.one.capitalize,
          entity.number,
          entity.commit.subject,
          entity.state,
          entity.color,
          entity.pull_request? ? "pull request" : "push",
          entity.branch_info,
          entity.commit.compare_url,
          formatter.duration(entity.duration),
          formatter.time(entity.started_at),
          formatter.time(entity.finished_at)
        ]

        if entity.respond_to? :jobs
          empty_line
          entity.jobs.each do |job|
            say [
              color("##{job.number} #{job.state}:".ljust(16), [job.color, :bold]),
              formatter.duration(job.duration).ljust(14),
              formatter.job_config(job.config),
              (color("(failure allowed)", :info) if job.allow_failures?)
            ].compact.join(" ").rstrip
          end
        else
          config = formatter.job_config(entity.config)
          say color("Allow Failure: ", :info) + entity.allow_failures?.inspect
          say color("Config:        ", :info) + config unless config.empty?
        end
      end
    end
  end
end

__END__

<[[ color("%s #%s: ", :bold) ]]> <[[ color(%p, :bold) ]]>
<[[ color("State:         ", :info) ]]><[[ color(%p, :%s) ]]>
<[[ color("Type:          ", :info) ]]>%s
<[[ color("Branch:        ", :info) ]]>%s
<[[ color("Compare URL:   ", :info) ]]>%s
<[[ color("Duration:      ", :info) ]]>%s
<[[ color("Started:       ", :info) ]]>%s
<[[ color("Finished:      ", :info) ]]>%s
