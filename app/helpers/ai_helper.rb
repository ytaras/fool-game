module AiHelper
	def create_game(cards = nil)
		AiGame.new(Game::create_game(cards))
	end

	class AiGame

		delegate :current_move, :table, :trump, :beat, :to => :game

		attr_reader :game

		def initialize(game)
			@game = game
		end

		def your_turn
			if current_move == :player2
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
				else
					@game.put(card_to_put)
				end
			end
		end

		private 

		def non_trumps
			game.player2_cards.select { |x| x.suit != game.trump }
    end

    def trumps
      game.player2_cards.select { |x| x.suit == game.trump }
    end

	end
end
