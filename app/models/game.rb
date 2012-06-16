require 'observer'

class Game
  include ConstantsHelper::GameConstants
  include Observable

  def self.create_game(options = {})
    if options.is_a?(Hash)
      starting_deck = options[:deck]
    else
      starting_deck = options
      options = {}
    end
    starting_deck ||= SORTED_DECK.shuffle
    Game.new(starting_deck, options)
  end

  attr_accessor :current_move
  attr_reader :deck, :trump_card, :table, :discarded, :winner

  delegate :trump_card, :trump, :to => :deck
  delegate :cards, :to => :player1, :prefix => :player1
  delegate :cards, :to => :player2, :prefix => :player2
  delegate :cards, :to => :table, :prefix => :table
  delegate :available, :to => :table

  def initialize(starting_deck, options = {})
    @deck = Deck.new(starting_deck)
    @hands = {:player1 => Hand.new, :player2 => Hand.new}
    @table = Table.new
    @table.trump = trump
    @discarded = []
    add_observer options[:listener] unless options[:listener].nil?
    next_move
  end

  def pass
    changed
    notify_observers :event => :dismiss, :cards => table.cards, :game => self
    table.cards.each { |e| @discarded.push e }
    table.clear
    next_move
  end

  def put(card)
    cards = @hands[current_move]
    if cards.put(card, table)
      changed
      notify_observers :event => :put, :card => card, :game => self
      true
    end
  end

  def take
    changed
    notify_observers :event => :take, :cards => table.cards, :player => current_defense, :game => self
    @hands[current_defense].take(table)
    next_move(false)
  end


  def beat(beating)
    if @hands[current_defense].beat(beating, table)
      changed
      notify_observers :event => :beat, :card => beating, :game => self
      true
    end
  end


  def to_s
    "" "
  Game
  	Deck #{deck.cards}
  	Player1 #{player1_cards}
  	Player2 #{player2_cards}
  	Table #{table.cards}
  	Trump #{trump_card}
  	Current move #{current_move}
    " ""
  end

  def player1
    @hands[:player1]
  end

  def player2
    @hands[:player2]
  end


  private

  def draw_cards(player)
    @hands[player].draw(@deck)
  end

  def smallest_trump(player)
    @hands[player].smallest_of(trump)
  end

  def current_defense
    if current_move == :player1
      :player2
    else
      :player1
    end
  end

  def next_move(turn = true)
    draw_cards(:player1)
    draw_cards(:player2)

    return if is_game_end

    if @current_move.nil?
      p1_trump = smallest_trump(:player1)
      p2_trump = smallest_trump(:player2)
      if p1_trump.nil?
        @current_move = :player2
      elsif p2_trump.nil?
        @current_move = :player1
      elsif p1_trump.card_number < p2_trump.card_number
        @current_move = :player1
      else
        @current_move = :player2
      end
    elsif turn
      @current_move = current_defense
    end

    changed
    notify_observers :event => :next_move, :game => self
  end

  def is_game_end
    p1 = @hands[:player1].empty?
    p2 = @hands[:player2].empty?
    return false unless p1 || p2
    if p1
      if p2
        @winner = :none
      else
        @winner = :player1
      end
    elsif p2
      @winner = :player2
    end
    changed
    notify_observers :event => :end, :game => self, :winner => winner
    true
  end

end
