class GameController < ApplicationController
  include AiHelper
  before_filter :authenticate_user!, :except => :index

  def index
  end

  def play
    @game = create_or_load_game
    gon.rabl
  end

  def move
    respond_to do |format|
      format.json {}.to_json
    end
  end

  private
  def create_or_load_game
    session[:game] ||= create_game
  end
end
