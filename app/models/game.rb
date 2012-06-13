class Game
  include ConstantsHelper::GameConstants
  # TODO Refactor - separate out few classes, probably table and hand

  def self.create_game(starting_deck = nil)
    starting_deck = SORTED_DECK.shuffle unless starting_deck
    Game.new(starting_deck)
  end

  attr_accessor :current_move
  attr_reader :deck, :player_cards, :trump_card, :table, :discarded, :winner

  delegate :trump_card, :trump, :to => :deck

  def initialize(starting_deck)
    @deck = Deck.new(starting_deck)
    @player_cards = {:player1 => [], :player2 => []}
    @table = []
    @discarded = []
    next_move
  end

  def pass
    table_cards.each { |e| @discarded.push e }
    table.clear
    next_move
  end

  def put(card)
    cards = player_cards[current_move]
    return unless table.empty? || available.include?(card.card)
    table << [card] if cards.delete(card)
  end

  def take
    cards = player_cards[current_defense]
    table_cards.each { |e| cards.push(e) }
    table.clear
    next_move(false)
  end

  def available
    table.flatten.map { |e| e.card }.uniq
  end

  def beat(beating)
    cards = player_cards[current_defense]
    return if table.empty? || table.last.size > 1
    to_beat = table.last[0]
    if beating.beats?(to_beat, trump) && cards.delete(beating)
      table.last << beating
    end
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

  def player1_cards
    player_cards[:player1]
  end

  def player2_cards
    player_cards[:player2]
  end

  private

  def table_cards
    table.flatten
  end

  def draw_cards(player)
    cards = player_cards[player]
    cards_to_draw = 6 - cards.size
    if cards_to_draw > 0
      deck.draw(cards_to_draw).each { |it| cards.push(it) }
    end
  end

  def smallest_trump(player)
    cards = player_cards[player]
    cards.select { |it| it.suit == trump }.min_by { |it| it.card_number }
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
