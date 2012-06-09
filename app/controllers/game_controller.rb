class GameController < ApplicationController
  include AiHelper
  before_filter :authenticate_user!, :except => :index

  def index
  end

  def create
    @game = create_game
  end
end
