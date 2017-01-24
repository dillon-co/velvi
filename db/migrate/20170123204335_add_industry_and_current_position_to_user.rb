class AddIndustryAndCurrentPositionToUser < ActiveRecord::Migration
  def change
    add_column :users, :industry, :string
    add_column :users, :current_position, :string
  end
end
