require 'rails_helper'

RSpec.describe Frame, type: :model do
  let(:game) { Game.create }
  let(:frame) { game.frames.find_by(number: game.current_frame) }

  describe '#roll' do
    context 'when current frame' do
      before do
        game.update(current_frame: 2)
      end
      
      it 'should save the game' do
        result = game.roll(2)
        
        expect(result).to be true
      end

      context 'when frame is invalid' do
        before do
          allow(game).to receive_message_chain(:frames, :find_by).and_return(frame)
          allow(frame).to receive(:roll).and_return(false)
          allow(frame).to receive_message_chain(:errors, :any?).and_return(true)
          allow(frame.errors).to receive(:full_messages).and_return(['Invalid frame'])
        end
        
        it 'should merge the errors' do
          result = game.roll(1)
          
          expect(result).to be false
          expect(game.errors.full_messages).to include('Invalid frame')
        end
      end
      
      context 'when frame is finished' do
        it 'should increment current frame' do
          expect { game.roll(10) }.to change { game.current_frame }.by(1)
        end
      end
    end
    
    context 'when game is finished' do
      before do
        game.update(current_frame: 11)
      end

      it 'should add error to an object' do
        game.roll(1)

        expect(game.errors[:base]).to include('The game is already finished')
      end
    end
  end

  describe '#remaining_pins_for_current_frame' do
    context 'when game is finished' do
      before do
        game.update(current_frame: 11)
      end

      it 'should return 0' do
        expect(game.remaining_pins_for_current_frame).to eq(0)
      end
    end
    
    context 'when game is not finished' do
      it 'should return 0' do
        game.roll(1)

        expect(game.remaining_pins_for_current_frame).to eq(9)
      end
    end
  end

  describe '#current_score' do
    context 'when points does not exist yet' do
      it 'returns 0' do
        expect(game.current_score).to eq(0)
      end
    end

    context 'when points exists' do
      let(:second_frame) { game.frames.second }
      
      before do
        frame.update(points: 1)
        second_frame.update(points: 2)
      end

      it 'returns maximum points from frames' do
        expect(game.current_score).to eq(2)
      end
    end
  end
end
