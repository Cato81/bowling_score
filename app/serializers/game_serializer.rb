class GameSerializer < ActiveModel::Serializer
  attributes :id, :current_frame, :remaining_pins
  attribute :total, if: :game_finished? 
  has_many :frames

  def total
    object.frames.last.points
  end

  def game_finished?
    object.current_frame == 11
  end

  def remaining_pins
    object.remaining_pins_for_current_frame
  end
end
