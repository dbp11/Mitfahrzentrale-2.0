class AddLastdeliveryToUsers < ActiveRecord::Migration
  def up
    add_column :users, :last_delivery, :datetime
    remove_column :messages, :last_delivery
  end
  def down
    remove_column :users, :last_delivery
    add_column :messages, :last_delivery, :datetime
  end
end
