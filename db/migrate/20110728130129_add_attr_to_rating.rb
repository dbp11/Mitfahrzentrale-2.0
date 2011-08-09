class AddAttrToRating < ActiveRecord::Migration
  def self.up
    add_column :ratings, :writer_id, :integer
    add_column :ratings, :receiver_id, :integer
    remove_column :ratings, :written_by_id
    remove_column :ratings, :sent_to_id
  end
  def self.down
    remove_column :ratings, :writer_id
    remove_column :ratings, :receiver_id
    add_column :ratings, :written_by_id, :integer
    add_column :ratings, :sent_to_id, :integer
  end
end
