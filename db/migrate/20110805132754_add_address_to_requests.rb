class AddAddressToRequests < ActiveRecord::Migration
  def up
    remove_column :requests, :address_start, :string
    remove_column :requests, :address_end, :string
    add_column :requests, :start_zipcode, :integer
    add_column :requests, :start_street, :string
    add_column :requests, :start_city, :string
    add_column :requests, :end_zipcode, :integer
    add_column :requests, :end_street, :string
    add_column :requests, :end_city, :string
  end
  def down
    add_column :requests, :address_start, :string
    add_column :requests, :address_end, :string
    remove_column :requests, :start_zipcode, :integer
    remove_column :requests, :start_street, :string
    remove_column :requests, :start_city, :string
    remove_column :requests, :end_zipcode, :integer
    remove_column :requests, :end_street, :string
    remove_column :requests, :end_city, :string
  end
end
