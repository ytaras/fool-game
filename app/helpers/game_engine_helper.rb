module GameEngineHelper
	SUITS = %w(spade heart diamond club)
	# TODO I don't know if it's good idea to mix numbers and symbols
	CARDS = %w(6 7 8 9 10 jack queen king ace)
	
	Card = Struct.new(:suit, :card)

	def create_game
		Game.new(sorted_deck.shuffle)
	end

	def sorted_deck
		cards = Array.new
		SUITS.each { |suit| CARDS.each { |card| cards.push Card.new(suit, card) }}
		cards
	end

	class Game
		attr_reader :deck_cards

		def initialize(starting_deck)
			@deck_cards = starting_deck.to_a
		end
	end
end
