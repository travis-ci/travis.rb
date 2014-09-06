require 'travis/cli'

module Travis
  module CLI
    class Accounts < ApiCommand
      description "displays accounts and their subscription status"

      def run
        authenticate
        accounts.each do |account|
          color = account.on_trial? ? :info : :green
          say [
            color(account.login, [color, :bold]),
            color("(#{account.name || account.login.capitalize}):", color),
            "#{description(account)},",
            account.repos_count == 1 ? "1 repository" : "#{account.repos_count} repositories"
          ].join(" ")
        end
        unless accounts.none?(&:on_trial?) or session.config['host'].nil?
          say session.config['host'], "To set up a subscription, please visit %s."
        end
      end

      def description(account)
        return "subscribed"          if account.subscribed?
        return "educational account" if account.educational?
        "not subscribed"
      end
    end
  end
end
