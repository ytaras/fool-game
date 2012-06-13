module AiHelper
  def create_game(cards = nil)
    AiGame.new(Game::create_game(cards))
  end

  class AiGame

    delegate :current_move, :table, :trump, :trump_card, :player1_cards, :to => :game

    attr_reader :game

    def deck
      @game.deck.length
    end

    def opponent
      @game.player1_cards.size
    end

    def put(card)
      if @game.put(card) && !my_move
        do_my_turn
      end
    end

    def beat(card)
      # TODO Find out how to do this with metaprogramming
      @game.beat(card)
      do_my_turn if my_move
    end

    def initialize(game)
      @game = game
      do_my_turn if my_move
    end

    def player_move
      !my_move
    end

    private
    def my_move
      @game.current_move == :player2
    end

    def do_my_turn
      if current_move == :player2
        do_attack()
      else
        do_defense()
      end
    end

    def do_defense
      raise "Trying to perform defense at empty table" if table.empty?
      card_to_beat = table.card_to_beat
      beating = @game.player2.beats(card_to_beat, trump).first
      if beating.nil?
        game.take
      else
        beat(beating)
      end
    end

    def do_attack
      card_sort = lambda { |x, y|
        x.card_number <=> y.card_number
      }

      card_filter = lambda { |x|
        game.available.include?(x.card)
      }

      if table.empty?
        # I should start
        card_to_put = non_trumps.sort(&card_sort).first
        card_to_put = trumps.sort(&card_sort).first if card_to_put.nil?
      else
        card_to_put = non_trumps.select(&card_filter).sort(&card_sort).first
        card_to_put = trumps.select(&card_filter).sort(&card_sort).first if card_to_put.nil?
      end

      if card_to_put.nil?
        @game.pass
      else
        put(card_to_put)
      end
    end

    private

    def non_trumps
      game.player2.none_of(game.trump)
    end

    def trumps
      game.player2.all_of(game.trump)
    end

  end
end
