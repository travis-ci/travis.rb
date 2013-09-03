require 'travis/cli'

module Travis
  module CLI
    class Accounts < ApiCommand
      description "displays accounts and their subscription status"

      def run
        authenticate
        accounts.each do |account|
          color = account.subscribed? ? :green : :info
          say [
            color(account.login, [color, :bold]),
            color("(#{account.name || account.login.capitalize}):", color),
            account.subscribed?      ? "subscribed,"  : "not subscribed,",
            account.repos_count == 1 ? "1 repository" : "#{account.repos_count} repositories"
          ].join(" ")
        end
        unless accounts.all?(&:subscribed?) or session.config['host'].nil?
          say session.config['host'], "To set up a subscription, please visit %s."
        end
      end
    end
  end
end
