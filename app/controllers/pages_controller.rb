class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def about
  end

  def price_page
    if current_user.parent_code.present?
      user = User.find_by(referral_code: current_user.parent_code)
      @friend = "#{user.first_name} #{user.last_name}"
    end
    !!(params[:j_id]) ? @job_id = params[:j_id] : nil
  end

  def profile
    if user_signed_in?
      @user = current_user
      @users_friends = User.where(parent_code: current_user.referral_code)
      @users_friends_count = @users_friends.count
      @job_links = @user.job_links.all
      @job_applications_count = @job_links.map { |j| j.job_applications.count }.inject(:+)
    end
  end

  def sharing
    if user_signed_in?
      @user = current_user
      @share_url = "#{root_url.split('//').last}ref?d=#{@user.referral_code}"
    end
  end

  def mission
  end

  def import_success
    @user = current_user
  end

  def single_application
    @job_link_id = params["j_id"]
    ## form, update job_link with info
    ## update job_link with users info if they want to apply just once
    ## or redirect to user sign_up page, send params

  end

  def loading
    job_link = JobLink.find(params['n_jid'])
    # respond_to do |format|
    #    format.json { render json: {success: job_link.done_searching? }}
    #  end
  end

  def add_user_resume_and_phone
    @user = current_user
    @job_id = params["j"]
    @job_link = JobLink.find(@job_id)
    @related_searches = @job_link.related_searches
  end

  def update_user
    user = current_user
    data_hash = Hash.new
    puts params
      data_hash[:phone_number] = params["user"]["phone_number"] unless user.phone_number.present?
      data_hash[:resume] = params["user"]["resume"] if params['user']["resume"] != nil
    data_hash[:credits] = user.credits - 1 if user.credits > 0
    if data_hash.length == 1 && user.phone_number.present? && user.resume.present?
      check_for_credits_and_redirect(user)
    elsif data_hash != {}
      user.update(data_hash)
      if user.save && data_hash[:resume] != nil
        user.job_links.last.call_search_worker
        redirect_to profile_path, notice: "Thanks! we'll find and apply to all the right jobs on your behalf."
      else
        redirect_to resume_and_phone_path(j: params['j']), notice: "All Fields Are Required"
      end
    else
      redirect_to resume_and_phone_path(j: params['j']), notice: "All Fields Are Required"
    end
  end

  def apply_to_related_searches
    RelatedSearchesWorker.perform_async(params)
    render nothing: true
  end

end
