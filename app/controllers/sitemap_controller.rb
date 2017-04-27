class SitemapController < ApplicationController
  layout nil
  def index
    headers['Content-Type'] = 'application/xml'
    respond_to do |format|
      format.xml {@job_links = JobLink.all}
    end
  end
end
