class RemoveResumeNotNullConstraint < ActiveRecord::Migration
  def change
    change_column :users, :resume_file_name, :string, null: true
    change_column :users, :resume_content_type, :string, null: true
    change_column :users, :resume_file_size, :string, null: true
    change_column :users, :resume_updated_at, :string, null: true
  end
end
