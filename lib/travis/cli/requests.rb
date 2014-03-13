require 'travis/cli'

module Travis
  module CLI
    class Requests < RepoCommand
      description "lists recent requests"
      on '-l', '--limit LIMIT', 'Maximum number requests to display'

      def run
        requests = repository.requests
        requests = requests[0, Integer(limit)] if limit
        requests.each do |request|
          style ||= :success if request.accepted?
          style ||= :error   if request.rejected?
          style ||= :info

          case request.event_type
          when 'push'
            result      = request.result || "received"
            message     = request.message
            message   ||= "validation pending"  unless request.rejected? or request.accepted?
            message   ||= "unknown reason"      unless request.accepted?
            message   ||= "triggered new build" unless request.rejected?
            description = "push to #{request.branch || request.tag || "???"}"
          when 'pull_request'
            result      = request.result || "received"
            message     = request.message
            message   ||= "HEAD commit not updated" unless request.accepted?
            message   ||= "triggered new build"     unless request.rejected?
            description = "push to #{request.branch || request.tag || "???"}"
            description = "PR ##{request.pull_request_number}"
          end

          say [
            color(description, [:bold, style]),
            color(result, style),
            color("(#{message})", style)
          ].join(" ").strip + "\n"

          say "  " + color(request.commit.short_sha, :bold) + " - " + request.commit.subject if request.commit
          say "  received at: #{formatter.time(request.created_at)}"
          empty_line
        end
      end
    end
  end
end
