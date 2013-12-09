require 'travis/cli'

module Travis
  module CLI
    class Cache < RepoCommand
      description 'lists or deletes repository caches'
      on '-d', '--delete',        'delete listed caches'
      on '-b', '--branch BRANCH', 'only list/delete caches on given branch'
      on '-m', '--match STRING',  'only list/delete caches where slug matches given string'
      on '-f', '--force',         'do not ask user to confirm deleting the caches'

      def run
        error "not allowed to access caches for #{color(repository.slug, :bold)}" unless repository.push?
        branches = caches.group_by(&:branch)
        check_caches

        warn "Deleted the following caches:\n" if delete?
        branches.each { |name, list| display_branch(name, list) }
        size = caches.inject(0) { |s,c| s + c.size }
        say "Overall size of above caches: " << formatter.file_size(size)
      end

      private

        def check_caches
          return if caches.any?
          say "no caches found"
          exit
        end

        def display_branch(name, list)
          say color(name ? "On branch #{name}:" : "Global:", :important)
          list.each { |c| display_cache(c) }
          puts
        end

        def display_cache(cache)
          say [
            color(cache.slug.ljust(space), :bold),
            "last modified: " << formatter.time(cache.last_modified),
            "size: " << formatter.file_size(cache.size)
          ].join("  ") << "\n"
        end

        def params
          params = {}
          params[:branch] = branch if branch?
          params[:match]  = match  if match?
          params
        end

        def caches
          @caches ||= drop? ? repository.delete_caches(params) : repository.caches(params)
        end

        def space
          @space ||= caches.map(&:slug).map(&:size).max
        end

        def drop?
          return false unless delete?
          return true if force?
          error "not deleting caches without --force" unless interactive?
          error "aborted" unless danger_zone? "Do you really want to delete #{description}?"
          true
        end

        def description
          description = color("all caches", :important)
          description << " on branch #{color(branch, :important)}" if branch?
          description << " that match #{color(match, :important)}" if match?
          description
        end
    end
  end
end
