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
          format.duration(entity.duration),
          format.time(entity.started_at),
          format.time(entity.finished_at)
        ]
      end
    end
  end
end

__END__

<[[ color("%s #%s: %s", :bold) ]]>
<[[ color("State:       ", :info) ]]><[[ color(%p, :%s) ]]>
<[[ color("Type:        ", :info) ]]>%s
<[[ color("Compare URL: ", :info) ]]>%s
<[[ color("Duration:    ", :info) ]]>%s
<[[ color("Started:     ", :info) ]]>%s
<[[ color("Finished:    ", :info) ]]>%s
