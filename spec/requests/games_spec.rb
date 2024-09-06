require 'rails_helper'

RSpec.describe 'Games', type: :request do
  let(:game) { Game.create }

  describe 'post /games' do
    it 'returns success' do
      post '/games'

      expect(response).to have_http_status :ok
    end
    
    it 'returns game object' do
      post '/games'
      response_object = JSON.parse(response.body)
      
      expect(response_object).to include('current_frame' => 1)
      expect(response_object['frames'].count).to eq 10
    end

    it 'creates a game' do
      expect { post '/games' }.to change(Game, :count).by(1)
    end
  end

  describe 'get /games' do
    before do
      2.times { Game.create }
    end

    it 'returns success' do
      get '/games'

      expect(response).to have_http_status :ok
    end
    
    it 'returns all games' do
      get '/games'
      response_object = JSON.parse(response.body)
      
      expect(response_object.count).to eq 2
    end

    it 'creates a game' do
      expect { post '/games' }.to change(Game, :count).by(1)
    end
  end

  describe 'get /games/:id' do
    it 'returns success' do
      get "/games/#{game.id}"

      expect(response).to have_http_status :ok
    end

    context 'when game does not exists' do
      it 'should return a 404 status and error message' do
        get "/games/dunno"
        response_object = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(response_object['message']).to eq 'Record Not Found'
      end
    end
  end

  describe 'patch /games' do
    context 'with success request' do
      before do
        patch "/games/#{game.id}", params: { pins_ko: 5 }
      end

      it 'should return success' do
        expect(response).to have_http_status :ok
      end
  
      it 'returns updated game object' do
        response_object = JSON.parse(response.body)
  
        expect(response_object).to include('current_frame' => 1)
        expect(response_object['frames'].first).to include('first_roll' => 5)
      end

      context 'when game does not exists' do
        it 'should return a 404 status and error message' do
          patch "/games/dunno"
          response_object = JSON.parse(response.body)
  
          expect(response).to have_http_status(:not_found)
          expect(response_object['message']).to eq 'Record Not Found'
        end
      end
    end


    context 'when incorrect number of knocked pins was sent' do
      before do
        put "/games/#{game.id}", params: { pins_ko: 24 }
      end

      it 'should not be success' do
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'should return an error' do
        response_object = JSON.parse(response.body)
        
        expect(response_object).to include('errors' => ["First roll must be a number between 0 and 10"])
      end
    end
  end

  describe 'delete /games' do
    before do
      delete "/games/#{game.id}"
    end

    it 'should return success' do
      expect(response).to have_http_status :no_content
    end

    context 'when game does not exists' do
      it 'should return a 404 status and error message' do
        delete "/games/dunno"
        response_object = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(response_object['message']).to eq 'Record Not Found'
      end
    end
  end
end
