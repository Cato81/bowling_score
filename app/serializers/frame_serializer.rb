class FrameSerializer < ActiveModel::Serializer
  attributes :id, :number, :points, :first_roll, :second_roll
  attribute :third_roll, if: :frame_ten? 

  def frame_ten?
    object.number == 10
  end
end
