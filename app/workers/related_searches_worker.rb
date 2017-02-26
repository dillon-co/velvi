
class RelatedSearchesWorker
  include Sidekiq::Worker
  def perform(p)
    j = JobLink.find(p['j'].to_i)
    u = j.user
    location, skill = j.job_location, j.skill_level
    puts "\n\n#{p}\n\n"
    u.update(credits: updated_credits(u, p['r_searches'].length))
    p['r_searches'].each do |s|
      jl = u.job_links.create(job_title: s, job_location: location, skill_level: skill)
      jl.call_search_worker
    end
  end

  def updated_credits(user, credits_used)
    user.credits - credits_used
  end
end
