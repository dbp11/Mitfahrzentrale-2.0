class AddAddressToTrip < ActiveRecord::Migration
  def up
    remove_column :trips, :address_start, :string
    remove_column :trips, :address_end, :string
    add_column :trips, :start_zipcode, :integer
    add_column :trips, :start_street, :string
    add_column :trips, :start_city, :string
    add_column :trips, :end_zipcode, :integer
    add_column :trips, :end_street, :string
    add_column :trips, :end_city, :string
  end
  def down
    add_column :trips, :address_start, :string
    add_column :trips, :address_end, :string
    remove_column :trips, :start_zipcode, :integer
    remove_column :trips, :start_street, :string
    remove_column :trips, :start_city, :string
    remove_column :trips, :end_zipcode, :integer
    remove_column :trips, :end_street, :string
    remove_column :trips, :end_city, :string
  end
end
