class AddDefaultValueToCurrentFrame < ActiveRecord::Migration[7.1]
  def change
    change_column :games, :current_frame, :integer, default: 1
  end
end
