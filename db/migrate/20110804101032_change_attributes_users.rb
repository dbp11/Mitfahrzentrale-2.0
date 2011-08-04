class ChangeAttributesUsers < ActiveRecord::Migration
  def up
    remove_column :users, :user_type, :boolean
    add_column :users, :role, :string
  end

  def down 
    add_column :users, :user_type, :boolean
    remove_column :users, :role, :string
  end
end
