
class RelatedSearchesWorker
  include Sidekiq::Worker
  def perform(p)
    j = ::JobLink.find(p['j'].to_i)
    location, skill = j.job_location, j.skill_level
    puts "\n\n#{p}\n\n"
    p['r_searches'].each do |s|
      jl = ::JobLlink.create(job_title: s, job_location: location, skill_level: skill)
      jl.call_search_worker
    end
  end
end
