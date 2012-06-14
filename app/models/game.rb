class Game
  include ConstantsHelper::GameConstants
  # TODO Refactor - separate out few classes, probably table and hand

  def self.create_game(starting_deck = nil)
    starting_deck = SORTED_DECK.shuffle unless starting_deck
    Game.new(starting_deck)
  end

  attr_accessor :current_move
  attr_reader :deck, :trump_card, :table, :discarded, :winner

  delegate :trump_card, :trump, :to => :deck
  delegate :cards, :to => :player1, :prefix => :player1
  delegate :cards, :to => :player2, :prefix => :player2
  delegate :cards, :to => :table, :prefix => :table
  delegate :available, :to => :table

  def initialize(starting_deck)
    @deck = Deck.new(starting_deck)
    @hands = {:player1 => Hand.new, :player2 => Hand.new}
    @table = Table.new
    @table.trump = trump
    @discarded = []
    next_move
  end

  def pass
    table_cards.each { |e| @discarded.push e }
    table.clear
    next_move
  end

  def put(card)
    cards = @hands[current_move]
    cards.put(card, table)
  end

  def take
    @hands[current_defense].take(table)
    next_move(false)
  end


  def beat(beating)
    @hands[current_defense].beat(beating, table)
  end

  def to_s
    "" "
		Game
			Deck #{deck_cards}
			Player1 #{player1_cards}
			Player2 #{player2_cards}
			Table #{table}
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

    if player1_cards.empty?
      if player2_cards.empty?
        @winner = :none
      else
        @winner = :player1
      end
    elsif player2_cards.empty?
      @winner = :player2
    end

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
  end

end
