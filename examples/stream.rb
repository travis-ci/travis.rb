require 'travis'

Travis.listen do |listener|
  listener.on("job:started")  { |e| puts "job started for #{e.repository.slug}"  }
  listener.on("job:finished") { |e| puts "job finished for #{e.repository.slug}" }
end