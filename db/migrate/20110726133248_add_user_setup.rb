class AddUserSetup < ActiveRecord::Migration

  # Einstellungen für Sichtbarkeit - true = sichtbar
  def up
    add_column :users, :email_notifications, :boolean
    add_column :users, :visible_phone, :boolean
    add_column :users, :visible_email, :boolean
    add_column :users, :visible_address,:boolean
    add_column :users, :visible_age, :boolean
    add_column :users, :visible_im, :boolean 
    add_column :users, :visible_cars, :boolean
  end

  def down
    remove_column :users, :email_notifications
    remove_column :users, :visible_phone
    remove_column :users, :visible_email
    remove_column :users, :visible_address
    remove_column :users, :visible_age
    remove_column :users, :visible_im
    remove_column :users, :visible_cars

  end
end
