class UpdateAddressAtTrip < ActiveRecord::Migration

  def up
    change_column_default(:users, :user_type , false) 
    change_column_default(:users, :sex, false) 
    change_column_default(:users, :email_notifications, false) 
    change_column_default(:users, :visible_phone, false) 
    change_column_default(:users, :visible_email, false)
    change_column_default(:users, :visible_address, false) 
    change_column_default(:users, :visible_age, false) 
    change_column_default(:users, :visible_im, false) 
    change_column_default(:users, :visible_cars, false) 
    change_column_default(:users, :visible_zip, false) 
    change_column_default(:users, :visible_city, false) 
    change_column_default(:users, :business, false)
  end
  def down
    change_column_default(:users, :user_type , false) 
    change_column_default(:users, :sex, false) 
    change_column_default(:users, :email_notifications, false) 
    change_column_default(:users, :visible_phone, false) 
    change_column_default(:users, :visible_email, false)
    change_column_default(:users, :visible_address, false) 
    change_column_default(:users, :visible_age, false) 
    change_column_default(:users, :visible_im, false) 
    change_column_default(:users, :visible_cars, false) 
    change_column_default(:users, :visible_zip, false) 
    change_column_default(:users, :visible_city, false) 
    change_column_default(:users, :business, false)
  end
end
