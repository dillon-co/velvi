class AddSkillLevelToJobLink < ActiveRecord::Migration
  def change
    add_column :job_links, :skill_level, :integer
  end
end
