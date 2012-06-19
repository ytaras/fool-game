module AiHelper
  def create_game(cards = nil)
    Game::create_game :listener => create_ai_listener, :deck => cards
  end

  def create_ai_listener
    AiListener.new
  end

  class AiListener
    def update(event)
      event_name = event[:event]
      send event_name, event if event_name && respond_to?(event_name)
    end


    def next_move(event)
      return unless my_move(event)
      do_attack event[:game]
    end

    def put(event)
      puts "my_move: #{my_move(event)}"
      return if my_move(event)
      do_defense event[:game]
    end

    def beat(event)
      return unless my_move(event)
      do_attack event[:game]
    end

    private

    def my_move(event)
      event[:game].current_move == :player2
    end

    def do_defense(game)
      raise "Trying to perform defense at empty table" if game.table.empty?
      card_to_beat = game.table.card_to_beat
      beating = game.player2.beats(card_to_beat, game.trump).first
      if beating.nil?
        game.take
      else
        game.beat(beating)
      end
    end

    def do_attack(game)
      non_trumps = game.player2.none_of(game.trump)
      trumps = game.player2.all_of(game.trump)
      card_sort = lambda { |x, y|
        x.card_number <=> y.card_number
      }

      card_filter = lambda { |x|
        game.available.include?(x.card)
      }

      unless game.table.empty?
        non_trumps = non_trumps.select(&card_filter)
        trumps = trumps.select(&card_filter)
      end

      card_to_put = non_trumps.sort(&card_sort).first
      card_to_put = trumps.sort(&card_sort).first if card_to_put.nil?

      if card_to_put.nil?
        game.pass
      else
        game.put(card_to_put)
      end
    end
  end
end
