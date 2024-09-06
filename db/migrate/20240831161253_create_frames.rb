class CreateFrames < ActiveRecord::Migration[7.1]
  def change
    create_table :frames do |t|
      t.integer :number
      t.integer :first_roll
      t.integer :second_roll
      t.integer :third_roll

      t.timestamps
    end
  end
end
