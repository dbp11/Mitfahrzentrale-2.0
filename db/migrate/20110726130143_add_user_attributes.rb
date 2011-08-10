class AddUserAttributes < ActiveRecord::Migration
  def self.up
    add_column :users, :user_type, :boolean
    add_column :users, :age, :integer
    add_column :users, :sex, :boolean
    add_column :users, :address, :string
    add_column :users, :addressN, :float
    add_column :users, :addressE, :float
    add_column :users, :zipcode, :integer
    add_column :users, :phone, :integer
    add_column :users, :instantmessenger, :string
    add_column :users, :city, :string

    end   
  
  def self.down
    remove_column :users, :user_type
    remove_column :users, :age
    remove_column :users, :sex
    remove_column :users, :address
    remove_column :users, :addressN
    remove_column :users, :addressE
    remove_column :users, :zipcode
    remove_column :users, :phone
    remove_column :users, :instantmessenger
    remove_column :users, :city
  end
end

