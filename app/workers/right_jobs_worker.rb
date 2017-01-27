class RightJobsWorker
  include Sidekiq::Worker
  def perform(job_link_id)
    begin
      puts "\n\n\n#{''*20}makeing sure each job is right#{''*20}\n\n\n"
      j = JobLink.find(job_link_id)
      j.check_for_job_search_accuracy
      j.job_applications.where(should_apply: true).each{ |a| a.apply_to_job }
    rescue => e
      puts e
    end
  end
end
