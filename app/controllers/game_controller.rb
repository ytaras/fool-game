class GameController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  def index
  end

  def create

  end
end
