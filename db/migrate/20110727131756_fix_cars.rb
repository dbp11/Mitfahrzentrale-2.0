class FixCars < ActiveRecord::Migration
  def up
    remove_column :cars, :type
    add_column :cars, :description, :string
  end

  def down
    add_column :cars, :type
    remove_column :cars, :description, :string
  end
end
