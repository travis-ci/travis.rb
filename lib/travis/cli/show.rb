require 'travis/cli'

module Travis
  module CLI
    class Show < RepoCommand
      def run(number = last_build.number)
        entity = job(number) || build(number)

        say template(__FILE__) % [
          entity.class.one.capitalize,
          entity.number,
          entity.commit.subject,
          entity.state,
          entity.color,
          entity.pull_request? ? "pull request" : "push",
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
            ].compact.join(" ")
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

<[[ color("%s #%s: %s", :bold) ]]>
<[[ color("State:         ", :info) ]]><[[ color(%p, :%s) ]]>
<[[ color("Type:          ", :info) ]]>%s
<[[ color("Compare URL:   ", :info) ]]>%s
<[[ color("Duration:      ", :info) ]]>%s
<[[ color("Started:       ", :info) ]]>%s
<[[ color("Finished:      ", :info) ]]>%s
