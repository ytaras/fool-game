class GameController < ApplicationController
  include AiHelper
  before_filter :authenticate_user!, :except => :index
  before_filter :validate_request, :only => :move

  VALID_MOVES = [:put, :beat]

  def index
  end

  def play
    @game = create_or_load_game
    gon.rabl

    respond_to do |format|
      format.html
      format.json
    end
  end

  def move
    @game = create_or_load_game
    log_observer = LogObserver.new
    changes = log_observer.watch_diff(@game) do
      @game.send params[:move].to_sym, parse_card(params[:card])
    end
    # Workaround on a RABL
    @changes = OpenStruct.new(changes)
    respond_to do |format|
      format.json
    end
  end

  private
  def create_or_load_game
    session[:game] ||= create_game
  end

  def validate_request
    unless !params[:move].nil? && VALID_MOVES.include?(params[:move].to_sym)
      respond_to do |format|
        format.json { render :json => {:error => 'action should be provided'}, :status => :bad_request }
      end
    end

    unless params[:card].nil? || (@card = parse_card(params[:card])).valid?
      respond_to do |format|
        format.json { render :json => {:error => @card.errors}, :status => :bad_request }
      end
    end
  end

  def parse_card(card)
    card = Card.new(card[:suit].to_sym, card[:card].to_sym)

  end

end
