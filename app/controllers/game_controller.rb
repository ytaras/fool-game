class GameController < ApplicationController
  include AiHelper
  before_filter :authenticate_user!, :except => :index

  def index
  end

  def play
    @game = create_or_load_game
  end

  private
  def create_or_load_game
    session[:game] ||= create_game
  end
end
