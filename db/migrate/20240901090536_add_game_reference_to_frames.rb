class AddGameReferenceToFrames < ActiveRecord::Migration[7.1]
  def change
    add_reference :frames, :game, null: false, foreign_key: true
  end
end
