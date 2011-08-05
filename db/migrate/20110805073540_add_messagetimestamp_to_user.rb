class AddMessagetimestampToUser < ActiveRecord::Migration
  def up
    add_column :messages, :last_delivery, :datetime
  end

  def down
    remove_column :messages, :last_delivery, :datetime
  end
end
