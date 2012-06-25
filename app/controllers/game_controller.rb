class GameController < ApplicationController
  include AiHelper
  before_filter :authenticate_user!, :except => :index
  before_filter :validate_request, :only => :move

  VALID_MOVES = [:put, :beat, :take, :pass]

  def index
  end

  def play
    @game = create_or_load_game
    session[:game] = @game = create_game if @game.winner
    gon.jbuilder

    respond_to do |format|
      format.html
      format.json
    end
  end

  def restart
    session[:game] = create_game
    redirect_to :action => :play
  end

  def move
    @game = create_or_load_game
    log_observer = LogObserver.new
    @changes = log_observer.watch_diff(@game) do
      parsed_card = parse_card(params[:card])
      if parsed_card.nil?
        @game.send params[:move].to_sym
      else
        @game.send params[:move].to_sym, parsed_card
      end
    end
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
    Card.new(card[:suit].to_sym, card[:card].to_sym) unless card.nil?
  end

end
