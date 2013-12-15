require 'travis'
repos = Travis::Repository.find_all(owner_name: 'travis-ci')
repos.each { |repo| puts "#{repo.slug} #{repo.last_build_state}" }
