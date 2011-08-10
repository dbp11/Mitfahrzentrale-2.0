class AddAuthorToRatings < ActiveRecord::Migration
  def self.up
    remove_column :ratings, :writer_id
    add_column :ratings, :author_id, :integer
  end
  def self.down
    add_column :ratings, :writer_id
    remove_column :ratings, :author_id, :integer
  end
end
