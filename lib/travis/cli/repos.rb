require 'travis/cli'

module Travis
  module CLI
    class Repos < ApiCommand
      description "lists repositories the user has certain permissions on"
      on('-m', '--match PATTERN', 'only list repositories matching the given pattern (shell style)')
      on('-o', '--owner LOGIN', 'only list repos for a certain owner')
      on('-n', '--name NAME', 'only list repos with a given name')
      on('-a', '--active', 'only list active repositories')
      on('-A', '--inactive', 'only list inactive repositories') { |c| c.active = false }
      on('-d', '--admin', 'only list repos with (or without) admin access')
      on('-D', '--no-admin', 'only list repos without admin access') { |c| c.admin = false }

      def run
        repositories.each do |repo|
          state_color = repo.active? ? :green : :yellow
          say color(repo.slug, [:bold, state_color]) + " "
          say color("(" << attributes(repo).map { |n,v| "#{n}: #{v ? "yes" : "no"}" }.join(", ") << ")", state_color)
          description = repo.description.lines.first.chomp unless repo.description.to_s.empty?
          say "Description: #{description || "???"}"
          empty_line unless repo == repositories.last
        end
      end

      def repositories
        @repositories ||= begin
          repos = session.hooks.concat(user.repositories).uniq
          session.preload(repos).sort_by(&:slug).select do |repo|
            next false unless match? repo.slug
            next false unless active.nil? or repo.active?    == active
            next false unless owner.nil?  or repo.owner_name == owner
            next false unless name.nil?   or repo.name       == name
            next false unless admin.nil?  or repo.admin?     == admin
            true
          end
        end
      end

      def attributes(repo)
        { "active" => repo.active?, "admin" => repo.admin?, "push" => repo.push?, "pull" => repo.pull? }
      end

      def match?(string)
        return true if match.nil?
        flags = File::FNM_PATHNAME | File::FNM_DOTMATCH
        flags |= File::FNM_EXTGLOB if defined? File::FNM_EXTGLOB
        File.fnmatch?(match, string, flags)
      end
    end
  end
end
