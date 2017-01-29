class AddApplicationSiteToJobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :application_site, :integer
  end
end
