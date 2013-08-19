require 'travis/cli'

module Travis
  module CLI
    class Sync < ApiCommand
      description "triggers a new sync with GitHub"

      on '-c', '--check',      'only check the sync status'
      on '-b', '--background', 'will trigger sync but not block until sync is done'
      on '-f', '--force',      'will force sync, even if one is already running'

      def run
        authenticate

        if check?
          say "#{"not " unless user.syncing?}syncing", "#{user.login} is currently %s"
        elsif user.syncing? and not force?
          error "user is already syncing"
        elsif background?
          say "starting synchronization"
          sync(false)
        else
          say "synchronizing: "
          sync
          say color(" done", :success)
        end
      end
    end
  end
end
