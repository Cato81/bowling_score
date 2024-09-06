class Frame < ApplicationRecord
  belongs_to :game

  validates :first_roll, :third_roll, 
            allow_nil: true,
            numericality: { 
              only_integer: true, 
              in: 0..10,
              message: "must be a number between 0 and 10"
            }
  validate :validate_number_of_pins_for_second_roll, if: :second_throw?
            

  def roll(pins)
    if finished?
      errors.add(:base, 'The frame is already finished')
      return false
    end
    
    set_throws

    if first_throw?
      self.first_roll = pins
      set_first_roll_points
    elsif second_throw?
      self.second_roll = pins
      set_second_roll_points
    elsif third_throw?
      self.third_roll = pins
      set_third_roll_points
    end
    
    self.save
  end

  def strike?
    return if self.first_roll.nil?

    self.first_roll == 10
  end
  
  def spare?
    return if self.first_roll.nil? || self.second_roll.nil?

    !strike? && (self.first_roll + self.second_roll == 10)
  end

  def first_throw?
    @first_throw 
  end

  def second_throw?
    @second_throw
  end

  def third_throw?
    @third_throw
  end

  def finished?
    if tenth_frame?
      regular_frame? || (strike? && self.third_roll.present?) || (spare? && self.third_roll.present?)
    else
      regular_frame? || spare? || strike? 
    end
  end

  def regular_frame?
    return if self.first_roll.nil? || self.second_roll.nil?

    self.first_roll + self.second_roll < 10
  end

  def tenth_frame?
    self.number == 10
  end

  def remaining_pins
    tenth_frame? ? 10 : 10 - self.first_roll.to_i
  end

  private

  def set_throws
    @first_throw ||= first_roll.nil?
    @second_throw ||= first_roll.present? && second_roll.nil?
    @third_throw ||=  tenth_frame? && self.second_roll.present?
  end

  def set_first_roll_points
    apply_previous_frame_bonus(self.first_roll) if previous_frame&.spare?
    apply_second_previous_frame_bonus if previous_frame&.strike? && second_previous_frame&.strike?
    self.update(second_roll: 0) if strike? && !tenth_frame?
  end

  def set_second_roll_points
    apply_previous_frame_bonus(self.first_roll, self.second_roll) if previous_frame&.strike?
    apply_current_frame_points(self.first_roll, self.second_roll) if regular_frame?
  end

  def set_third_roll_points
    apply_current_frame_points(self.first_roll, self.second_roll, self.third_roll) if self.first_roll && self.second_roll
  end

  def apply_previous_frame_bonus(first_roll_points, second_roll_points = 0)
    bonus = first_roll_points + second_roll_points + 10
    previous_frame.update(points: self.game.current_score + bonus)
  end
  
  def apply_second_previous_frame_bonus
    bonus = self.first_roll + 20
    second_previous_frame.update(points: self.game.current_score + bonus)
  end

  def apply_current_frame_points(first_roll_points, second_roll_points, third_roll_points = 0)
    total = first_roll_points + second_roll_points + third_roll_points
    self.update(points: self.game.current_score + total)
  end

  def previous_frame
    @previous_frame ||= self.game.frames.find_by(number: self.number - 1)
  end
  
  def second_previous_frame
    @second_previous_frame ||= self.game.frames.find_by(number: self.number - 2)
  end

  def validate_number_of_pins_for_second_roll
    if invalid_pins_for_second_roll?
      errors.add(:second_roll, "must be a number between 0 and #{remaining_pins}")
    end
  end

  def invalid_pins_for_second_roll?
    (total_pins > 10 && !tenth_frame?) || (second_roll.to_i > 10 and tenth_frame?)
  end

  def total_pins
    first_roll.to_i + second_roll.to_i
  end
end
