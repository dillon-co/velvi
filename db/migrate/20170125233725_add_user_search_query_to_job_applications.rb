class AddUserSearchQueryToJobApplications < ActiveRecord::Migration
  def change
    add_column :job_applications, :user_search_query, :string
  end
end
