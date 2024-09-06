class GamesController < ApplicationController
  before_action :game, only: %i[show destroy]
  
  def index
    render json: Game.all
  end

  def show
    render json: game
  end

  def create
    @game = Game.new

    if game.save
      render json: game, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Validation failed',
        errors: game.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if game.roll(params[:pins_ko].to_i)
      render json: game, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Validation failed',
        errors: game.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    game.destroy!

    head :no_content
  end

  private

  def game
    @game ||= Game.find params[:id]
  end
end
