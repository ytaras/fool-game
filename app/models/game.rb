class Game 
	SUITS = %w(Spade Heart Diamond Club)
	CARDS = %w(6 7 8 9 10 Jack Queen King Ace)
	
	SORTED_DECK = Array.new
	SUITS.each { |suit| CARDS.each { |card| SORTED_DECK.push Card.new(suit, card) }}
	
	def self.create_game(starting_deck = nil)
		starting_deck = SORTED_DECK.shuffle unless starting_deck
		Game.new(starting_deck)
	end

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

	def draw_cards(player)
		player_cards = send(player.to_s + "_cards")
		cards_to_draw = 6 - player_cards.size
		if(cards_to_draw > 0)
			deck_cards.pop(cards_to_draw).each { |it| player_cards.push(it) }
		end
	end

	def smallest_trump(player)
		player_cards = send(player.to_s + "_cards")
		player_cards.select { |it| it.suit == @trump }.map { |it| it.card }.min_by { |it| CARDS.find_index(it) }
	end
end
