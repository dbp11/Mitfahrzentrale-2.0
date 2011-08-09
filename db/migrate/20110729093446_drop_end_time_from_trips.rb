class DropEndTimeFromTrips < ActiveRecord::Migration
  def up
    remove_column :trips, :end_time
  end

  def down
    add_column :trips, :end_time, :datetime
  end
end
