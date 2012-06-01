module GameEngineHelper
	SUITS = %w(Spade Heart Diamond Club)
	CARDS = %w(6 7 8 9 10 Jack Queen King Ace)
	
	def create_game(starting_deck = nil)
		starting_deck = sorted_deck.shuffle unless starting_deck
		Game.new(starting_deck)
	end

	# TODO sorted deck should be created only once
	def sorted_deck
		cards = Array.new
		SUITS.each { |suit| CARDS.each { |card| cards.push Card.new(suit, card) }}
		cards
	end

	# TODO This probably should be moved to model
	class Game
		attr_accessor :current_move
		attr_reader :deck_cards, :player1_cards, :player2_cards, :trump, :table

		def initialize(starting_deck)
			@deck_cards = starting_deck.to_a
			@player1_cards = []
			@player2_cards = []
			@trump = @deck_cards.first.suit
			@table = []
			next_move
		end

		def next_move
			draw_cards(:player1)
			draw_cards(:player2)
			if(@current_move.nil?)
				p1_trump = smallest_trump(:player1)
				p2_trump = smallest_trump(:player2)
				if(p1_trump.nil?)
					@current_move = :player2
				elsif p2_trump.nil?
			 		@current_move = :player1
			 	elsif p1_trump < p2_trump
			 		@current_move = :player1
				else
					@current_move = :player2
				end
			end
		end

		def to_s
			"""
			Game
				Deck #{deck_cards}
				Player1 #{player1_cards}
				Player2 #{player2_cards}
				Trump #{trump}
				Current move #{current_move}
			"""
		end		

		private 

		def smallest_trump(player)
			player_cards = send(player.to_s + "_cards")
			player_cards.select { |it| it.suit == @trump }.map { |it| it.card }.min_by { |it| CARDS.find_index(it) }
		end

		def draw_cards(player)
			player_cards = send(player.to_s + "_cards")
			cards_to_draw = 6 - player_cards.size
			if(cards_to_draw > 0)
				deck_cards.pop(cards_to_draw).each { |it| player_cards.push(it) }
			end
		end
	end

	class Card
		attr_reader :suit, :card
		def initialize(suit, card)
			@suit = suit
			@card = card
		end
		def to_s
			"#{card} of #{suit}"
		end

		def ==(other)
			@suit == other.suit && @card == other.card
		end
	end
end
