class Game < ApplicationRecord
  has_many :frames, dependent: :destroy
  after_create :set_frames

  def roll(pins)
    if finished?
      errors.add(:base, 'The game is already finished')
      return false
    end

    frame = self.frames.find_by(number: self.current_frame)
    frame.roll(pins)
    self.current_frame += 1 if frame.finished?
    
    if frame.errors.any?
      merge_frame_errors(frame) 
      false
    else 
      self.save
    end
  end

  def finished?
    self.current_frame == 11
  end

  def current_score
    self.frames.maximum(:points).presence || 0
  end

  def remaining_pins_for_current_frame
    return 0 if finished?

    frame = self.frames.find_by(number: self.current_frame)
    frame.remaining_pins
  end

  private

  def set_frames
    10.times { |frame| self.frames.create(number: frame + 1)}
  end

  def merge_frame_errors(frame)
    frame.errors.full_messages.each {|msg| errors.add(:base, msg)} 
  end
end
