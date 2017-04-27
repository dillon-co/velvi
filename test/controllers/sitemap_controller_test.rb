require 'spec_helper'

feature 'Sitemap' do
  scenario 'shows site map' do
    job = create(:job_link, :job_title => "my post", :user_id => 6)
    visit "sitemap.xml"
    expect(page).to have_content "my post"
  end
end
