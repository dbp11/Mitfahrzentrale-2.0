class ChangeUserAttributes < ActiveRecord::Migration
  def up
    remove_column :users, :picture_file_name
    remove_column :users, :picture_content_type
    remove_column :users, :picture_file_size
    remove_column :users, :picture_updated_at
    add_column :users, :pic_file_name
    add_column :users, :pic_content_type
    add_column :users, :pic_file_size
    add_column :users, :pic_updated_at
  end

  def down
    add_column :users, :picture_file_name, :string
    add_column :users, :picture_content_type, :string
    add_column :users, :picture_file_size, :integer
    add_column :users, :picture_updated_at, :datetime
    remove_column :users, :pic_file_name
    remove_column :users, :pic_content_type
    remove_column :users, :pic_file_size
    remove_column :users, :pic_updated_at
  end
end
