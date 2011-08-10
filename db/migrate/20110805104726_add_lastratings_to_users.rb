class AddLastratingsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :last_ratings, :datetime
  end

  def down
    remove_column :users, :last_ratings
  end
end
