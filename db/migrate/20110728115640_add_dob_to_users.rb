class AddDobToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birthday, :date
    remove_column :users, :age
  end
  def self.down
    remove_column :users, :birthday
    add_column :users, :age, :integer
  end
end
