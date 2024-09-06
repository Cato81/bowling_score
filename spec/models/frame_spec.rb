require 'rails_helper'

RSpec.describe Frame, type: :model do
  let(:game) { Game.create }

  describe 'validations' do
    it 'is valid if rolls are between 0 and 10' do
      frame = Frame.new(first_roll: 7, second_roll: 2, game: game)
      
      expect(frame).to be_valid
    end

    it 'is invalid if first roll is greater than 10' do
      frame = Frame.new(first_roll: 11, game: game)

      expect(frame).not_to be_valid
      expect(frame.errors[:first_roll]).to include('must be a number between 0 and 10')
    end

    it 'is invalid if second roll is greater than 10' do
      frame = Frame.new(first_roll: 0, second_roll: 11, game: game)
      allow(frame).to receive(:second_throw?).and_return(true)

      expect(frame).not_to be_valid
      expect(frame.errors[:second_roll]).to include('must be a number between 0 and 10')
    end

    it 'is invalid if the sum of first and second roll is greater than 10' do
      frame = Frame.new(first_roll: 0, second_roll: 11, game: game)
      allow(frame).to receive(:second_throw?).and_return(true)

      expect(frame).not_to be_valid
      expect(frame.errors[:second_roll]).to include('must be a number between 0 and 10')
    end

    context 'when tenth frame' do
      before do
        game.update(current_frame: 10)
      end

      it 'is valid if rolls are between 0 and 10' do
        frame = Frame.new(first_roll: 10, second_roll: 1, third_roll: 10, game: game)

        expect(frame).to be_valid
      end

      it 'is invalid if third roll is greater than 10' do
        frame = Frame.new(first_roll: 10, second_roll: 1, third_roll: 11, game: game)
  
        expect(frame).not_to be_valid
        expect(frame.errors[:third_roll]).to include('must be a number between 0 and 10')
      end
    end
    
  end

  describe '#roll' do
    context 'with first roll' do
      let(:frame) { game.frames.first }

      it 'saves number of knocked out pins for first roll of the given frame' do
        frame.roll(3)

        expect(frame.reload.first_roll).to eq 3
      end
      
      context 'when first roll is strike' do  
        it 'finishes the current frame' do
          frame.roll(10)

          expect(frame.finished?).to be_truthy
        end

        context 'when tenth frame' do
          let(:frame) { game.frames.last }
          
          before do
            game.update(current_frame: 10)
          end
          
          it 'does not finish the current frame' do
            frame.roll(10)

            expect(frame.finished?).to be_falsey
          end
        end
      end

      context 'when previous frame have spare' do
        before do
          game.update(current_frame: 2)
          frame.update(first_roll: 8, second_roll: 2)
        end

        it 'sets the points for previous frame' do
          game.frames.second.roll(4)

          expect(frame.reload.points).to eq 14
        end
      end

      context 'when second previous and previous frames have strike' do
        before do
          game.update(current_frame: 3)
          game.frames.first(2).each do |frame| 
            frame.update(first_roll: 10)
          end
        end

        it 'sets the points for second previous frame' do
          game.frames.third.roll(4)
          second_previous_frame = game.frames.first

          expect(second_previous_frame.points).to eq 24
        end
      end
    end

    context 'with second roll' do
      let(:first_frame) { game.frames.first }
      let(:second_frame) { game.frames.second }

      before do
        first_frame.update(first_roll: 5)
      end

      it 'saves number of knocked out pins for second roll of the given frame' do
        first_frame.roll(3)
        
        expect(first_frame.reload.second_roll).to eq 3
      end
      
      it 'finishes the current frame' do
        first_frame.roll(3)

        expect(first_frame.finished?).to be_truthy
      end

      context 'when frame with no bonus rolls' do
        it 'sets the points for the current frame' do
          first_frame.roll(3)
          
          expect(first_frame.points).to eq 8
        end
      end

      context 'when spare' do
        it 'does not set the points for the current frame' do
          first_frame.roll(5)
          
          expect(first_frame.points).to be nil
        end
      end

      context 'when previous frame have strike' do
        before do
          game.update(current_frame: 2)
          first_frame.update(first_roll: 10)
          second_frame.update(first_roll: 5)
        end

        it 'set the points for previous frame' do
          second_frame.roll(4)

          expect(first_frame.reload.points).to eq 19
        end
      end
    end
    
    context 'with third roll' do
      let(:tenth_frame) { game.frames.find_by(number: 10) }

      before do
        game.update(current_frame: 10)
      end

      context 'when first roll is strike' do
        before do
          tenth_frame.update(first_roll: 10, second_roll: 5)
        end

        it 'sets the current frame points' do
          tenth_frame.roll(4)

          expect(tenth_frame.reload.points).to eq 19
        end
      end
      
      context 'when second roll is spare' do
        before do
          tenth_frame.update(first_roll: 5, second_roll: 5)
        end

        it 'sets the current frame points' do
          tenth_frame.roll(4)

          expect(tenth_frame.reload.points).to eq 14
        end
      end
    end

    context 'when frame is already finished' do
      let(:frame) { game.frames.first }

      before do
        frame.update(first_roll: 8, second_roll: 2)
      end

      it 'should add error to an object' do
        frame.roll(1)

        expect(frame.errors[:base]).to include('The frame is already finished')
      end
    end
  end

  describe '#finished?' do
    context 'when regular frame' do
      let(:frame) { game.frames.first }

      context 'with no bonus rolls' do
        it 'returns truthy' do
          frame.update(first_roll: 5, second_roll: 3)
  
          expect(frame.finished?).to be_truthy
        end
      end

      context 'with strike' do        
        it 'returns truthy' do
          frame.update(first_roll: 10)
          
          expect(frame.finished?).to be_truthy
        end
      end

      context 'with spare' do
        it 'finises the frame' do
          frame.update(first_roll: 5, second_roll: 5)
          
          expect(frame.finished?).to be_truthy
        end
      end
    end
    
    context 'when tenth frame' do
      let(:frame) { game.frames.find_by(number: 10) }

      context 'when no bonus rolls' do
        it 'returns truthy' do
          frame.update(first_roll: 5, second_roll: 3)

          expect(frame.finished?).to be_truthy
        end
      end
      
      context 'with first roll as a strike' do
        it 'returns truthy with all rolls finished' do
          frame.update(first_roll: 10, second_roll: 3, third_roll: 1)

          expect(frame.finished?).to be_truthy
        end
        
        it 'returns falsy with only first rolls finished' do
          frame.update(first_roll: 10)

          expect(frame.finished?).to be_falsy
        end
      end
      
      context 'with second roll as a spare' do
        it 'returns truthy with all rolls finished' do
          frame.update(first_roll: 5, second_roll: 5, third_roll: 1)

          expect(frame.finished?).to be_truthy
        end

        it 'returns falsy with first and second roll finished' do
          frame.update(first_roll: 5, second_roll: 5)

          expect(frame.finished?).to be_falsy
        end
      end
    end
  end

  describe '#remaining_pins' do
    context 'when not tenth frame' do
      it 'should return remaining number of pins' do
        frame = Frame.new(first_roll: 3, game: game)

        expect(frame.remaining_pins).to eq 7
      end
    end
    
    context 'when tenth frame' do
      it 'should return 10' do
        frame = Frame.new(number: 10, first_roll: 3, game: game)

        expect(frame.remaining_pins).to eq 10
      end
    end
  end
end
