class GameController < ApplicationController
  def index
    @object = "Sgrin"
    respond_to do |format|
      format.html
    end
  end
end
