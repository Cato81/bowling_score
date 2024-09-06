class AddPointsToFrames < ActiveRecord::Migration[7.1]
  def change
    add_column :frames, :points, :integer
  end
end
