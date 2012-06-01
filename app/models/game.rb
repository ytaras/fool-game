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
	attr_reader :deck_cards, :player_cards, :trump, :table

	def initialize(starting_deck)
		@deck_cards = starting_deck.to_a
		@player_cards = {:player1 => [], :player2 => []}
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

	def put(card)
		cards = player_cards[current_move]
		table.push(card => nil) if cards.delete(card)
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

	def player1_cards
		player_cards[:player1]
	end

	def player2_cards
		player_cards[:player2]
	end

	private

	def draw_cards(player)
		cards = player_cards[player]
		cards_to_draw = 6 - cards.size
		if(cards_to_draw > 0)
			deck_cards.pop(cards_to_draw).each { |it| cards.push(it) }
		end
	end

	def smallest_trump(player)
		cards = player_cards[player]
		cards.select { |it| it.suit == @trump }.map { |it| it.card }.min_by { |it| CARDS.find_index(it) }
	end

end
