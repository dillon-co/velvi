# == Schema Information
#
# Table name: job_applications
#
#  id                :integer          not null, primary key
#  user_name         :string
#  user_email        :string
#  user_phone_number :string
#  user_resume_path  :string
#  user_cover_letter :string
#  indeed_link       :string
#  title             :string
#  company           :string
#  location          :string
#  pay_rate          :string
#  applied_to        :boolean          default(FALSE)
#  pay_type          :integer
#  description       :text
#  job_link_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  should_apply      :boolean          default(TRUE)
#  user_skill_level  :integer
#  user_search_query :string
#  application_site  :integer
#

require 'capybara/poltergeist'
require 'open-uri'
require 'watir'
require 'mechanize'
require 'open-uri'
require 'ots'

# require 'watir-webdriver'
# require 'watir-webdriver/wait'
require 'headless'
# T0DO: FIll OUT FORMS Generically ¿¿Watson API??

class JobApplication < ActiveRecord::Base
  belongs_to :job_link
  # after_save :apply_to_job, unless: :applied_to

  enum user_skill_level: {
    'beginner' => 0,
    'intermediate' => 1,
    'advanvced' => 2
  }

  enum application_site: ['amazon', 'indeed']

  def apply_to_job
    if application_site == "amazon"
      apply_from_amazon
    else
      apply_from_indeed
    end
  end

  def apply_from_indeed
    @counter = 0
    if self.should_apply == true
      until self.applied_to == true || @counter == 3
        begin
        puts "\n\n\n\n\n#{'∞∞∞∞∞∞∞'*20}\n\n#{indeed_link} ---------- id: #{id}\n\n\n\n"

        browser = Watir::Browser.new :phantomjs, :args => ['--ssl-protocol=tlsv1']
        # browser.driver.manage.timeouts.implicit_wait = 3 #3 seconds
        browser.goto indeed_link
        if open_modal(browser)
          puts "clicked modal button"
          sleep 3.5
          if browser.iframe(id: /indeed-ia/).exists?
            puts "found"
            # byebug
            input_frame = browser.iframe(id: /indeed-ia/).iframe
              if input_frame.text_field(id: 'applicant.name').present? || input_frame.text_field(id: 'applicant.firstName').present?
                  fill_out_modal_with_text_first(input_frame)
              else
                fill_out_modal_with_text_last(input_frame)
              end
              self.update(applied_to: true)
          end
        end
        rescue => e
          puts e
        end
        clean_up_temporary_binary_file
        browser.close
        @counter += 1
      end
    end
  end

  def apply_from_amazon
    agent = Mechanize.new
    agent.get indeed_link
    agent.get agent.get agent.page.iframes.first.uri
    fill_out_amazon_form(agent)
  end

  def fill_out_amazon_form(agent)
    puts "\n\n\nWorkin on it\n\n\n"
  end

   def fill_out_modal_with_text_first(input_frame)
    fill_out_text_form(input_frame)
    if input_frame.button(id: 'apply').present?
      input_frame.button(id: 'apply').click
      puts "applied"
    else
      input_frame.a(class: 'button_content', text: 'Continue').when_present.click
      click_checkboxes(input_frame)
      if input_frame.button(id: 'apply').present?
        input_frame.button(id: 'apply').click
        puts "applied"
      else
        input_frame.a(class: 'button_content').click
        click_checkboxes(input_frame)
        input_frame.button(id: 'apply').click
        puts "applied"
      end
    end
  end


  def fill_out_modal_with_text_last(input_frame)
    click_checkboxes(input_frame)
    fill_out_text_form(input_frame)
    input_frame.button(id: 'apply').click
  end

  def fill_out_name(input_frame)
    if input_frame.text_field(id: 'applicant.name').present?
      fill_out_text_like_a_human(input_frame.text_field(id: 'applicant.name'), user_name)
    else
      fill_out_text_like_a_human(input_frame.text_field(id: 'applicant.firstName'), user_name.split(' ').first)
      fill_out_text_like_a_human(input_frame.text_field(id: 'applicant.lastName'), user_name.split(' ').last)
    end
  end

  def fill_out_text_like_a_human(field, text)
    text_array = text.split('', 4)
    text_array.each {|letters| field.set letters }
    field.set text
  end


  def fill_out_text_form(input_frame)
    puts "filling out name"
    fill_out_name(input_frame)
    puts "filling out email"
    fill_out_text_like_a_human(input_frame.text_field(id: 'applicant.email'), user_email)
    puts "filling out phone number"
    fill_out_text_like_a_human(input_frame.text_field(id: 'applicant.phoneNumber'), user_phone_number)#user.phone_number if user.phone_number != nil
    puts "uploading resume"
    input_frame.file_field.set user_resume
    puts "writing cover letter"
    if user_cover_letter != nil
      fill_out_text_like_a_human(input_frame.text_field(id: 'applicant.applicationMessage'), user_cover_letter)
    end  
    # byebug
  end

  def click_checkboxes(input_frame)
    puts "checkin boxes"
    input_frame.div(id: "q_0").when_present do
      puts "radio frame is present"
      %w(0 1 2 3 4).each do |question_number|
        if input_frame.div(id: "q_#{question_number}").present?
          puts "found radio # #{question_number}"
          input_frame.div(id: "q_#{question_number}").radio(value: "0").set
        else
          next
        end
      end
    end
    puts "boxes checked"
  end

  def open_modal(browser)
    puts "not found"
    if browser.span(text: "Apply Now").exists?
      puts "found at browser.span(text: 'Apply Now')"
      browser.span(text: "Apply Now").click
      true
    elsif browser.span(id: /indeed-ia/).exists?
      puts "found at browser.span(id: /indeed-ia/)"
      browser.span(id: /indeed-ia/).click
      true
    elsif browser.a(id: /indeed-ia/).exists?
      puts "found at browser.a(id: /indeed-ia/)"
      browser.a(class: /indeed-id/).click
      true
    elsif browser.span(class: "indeed-apply-button-inner").exists?
      puts "found at browser.span(class: 'indeed-apply-button-inner')"
      browser.span(class: "indeed-apply-button-inner").click
    else
      puts "cant find"
      false
    end
  end



  def check_should_apply
    agent = Mechanize.new
    agent.get(indeed_link)
    puts agent.page.uri
    if agent.page.uri.to_s.match(/indeed/)
      get_and_update_from_indeed(agent)
    elsif agent.page.uri.to_s.match(/amazon/)
      get_and_update_from_amazon(agent)
    else
      puts "\n\n NOT HERE \n\n"
      self.update(should_apply: false)
    end
  end

  def update_based_on_job_description(search_and_skill_level_match, app_site)
    if search_and_skill_level_match.first >= 50 && search_and_skill_level_match.second == true
      puts "\n YES \n"
      self.update(should_apply: true, application_site: app_site)
    else
      puts "\n MEOW \n"
      self.update(should_apply: false, application_site: app_site)
    end
  end

  def get_and_update_from_indeed(agent)
    s = compare_indeed_skill_requirements(agent)
    update_based_on_job_description(s, "indeed")
  end

  def get_and_update_from_amazon(agent)
    agent.get agent.page.iframes.first.uri
    s = compare_amazon_skill_requirements(agent)
    update_based_on_job_description(s, "amazon")
  end

  def compare_amazon_skill_requirements(agent)
    qualifications = agent.page.search("div[@itemprop='responsibilities']").children.text
    full_description = agent.page.search('.iCIMS_JobContainer').children.map {|c| c.text }
    required_years = get_all_years_in_description(qualifications)
    search_percent_match = match_keywords_from_summary_with_search_query(full_description)
    [search_percent_match, skill_levels_match?(required_years)]
  end

  def compare_indeed_skill_requirements(agent)
    years_and_summary = get_indeed_required_years_and_summary(agent)
    search_match_percent = match_keywords_from_summary_with_search_query(years_and_summary.last)
    [search_match_percent, skill_levels_match?(years_and_summary.first)]
  end

  def match_keywords_from_summary_with_search_query(sum)
    all_words = sum.join(' ')
    words_matched = 0
    parsed_summary = OTS.parse(all_words)
    query_array = user_search_query.split(' ')
    query_array.each do |s|
      words_matched += 1 if parsed_summary.keywords.include?(s.downcase) || parsed_summary.keywords.include?(s)
    end
    search_percent_match = (words_matched.to_f / query_array.length.to_f)*100
    return search_percent_match
  end

  def skill_levels_match?(required_years)
    average_required_years = get_average_required_years(required_years)
    required_skill_level = years_to_skill_level(average_required_years)
    required_skill_level == user_skill_level ? true : false
  end

  def get_indeed_required_years_and_summary(agent)
    summary_attributes = agent.page.search("#job_summary").first.children.map { |c| c.text.to_s }
    required_experience = []
    summary_attributes.each_with_index do |attribute, ind|
      if attribute.split(' ').map!{|w| w.downcase}.include?('experience:')
        required_experience << summary_attributes[ind+1]
      end
    end
    required_years = get_all_years_in_description(required_experience.join(" "))
    [required_years, summary_attributes]
  end

  def get_average_required_years(arr)
    arr.length > 0 ? (arr.inject(:+) / arr.length) : user_skill_level
  end

  def get_all_years_in_description(req_ex)
    req_ex.gsub(/\D/, " ").split(" ").map { |n| n.to_i }
  end

  def years_to_skill_level(required_years)
    if required_years < 3
      return 'beginner'
    elsif required_years.between?(3, 5)
      return 'intermediate'
    elsif required_years >= 5
      return "advanced"
    end
  end

  def user_resume
    Aws.config.update({
      region: 'us-east-1',
      credentials: Aws::Credentials.new(ENV['AMAZON_ACCESS_KEY_ID'], ENV['AMAZON_SECRET_ACCESS_KEY'])
    })
    s3 = Aws::S3::Client.new
    create_temp_file
    store_and_return_user_resume(s3)
  end

  def create_temp_file
    File.new(local_file_path, "w+")
  end

  def store_and_return_user_resume(s3)
    File.open(local_file_path, "w+") { |f| f.write(resume_object(s3).read)}
    File.absolute_path(local_file_path)
  end

  def local_file_path
    "public/#{user_resume_path.split('/').last}"
  end

  def clean_up_temporary_binary_file
    File.delete(local_file_path) if File.exist?(local_file_path)
  end

  def resume_object(s3)
    s3.get_object(bucket: 'job-bot-bucket', key: user_resume_path).body
  end
end
