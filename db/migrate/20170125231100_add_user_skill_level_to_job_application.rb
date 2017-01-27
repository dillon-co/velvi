class AddUserSkillLevelToJobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :user_skill_level, :integer
  end
end
