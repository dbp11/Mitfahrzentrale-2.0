class DropTrunkFromCars < ActiveRecord::Migration
  def up
    remove_column :cars, :trunk
  end

  def down
    add_column :cars, :trunk, :string
  end
end
