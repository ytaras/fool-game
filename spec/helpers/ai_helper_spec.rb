require 'spec_helper'
#TODO Instead of creating AiGame which wraps Game it should be pluggable game with teams 
# and AI < Team and Human < Team

describe AiHelper do
	before(:each) do
		@game = helper.create_game
	end
	it "creates AI game" do
		@game.should_not == nil
	end

	it "throws least not-trump card on a table if starts" do
		@game = helper.create_game(Array.new(Game::SORTED_DECK))
		@game.current_move.should == :player2
		# TODO I don't know if i need this method really but it's for sake of testing
		@game.your_turn
		@game.table.keys.should include(Card.new(:Club, :"6"))
	end

	it "should throw same card if can" do
		def verify_and_beat(p2suit, p2card, p1suit, p1card) 
			@game.your_turn
			@game.table.keys.should include(Card.new(p2suit, p2card))
			@game.beat(Card.new(p1suit, p1card))
		end
		@game = helper.create_game([
			# Player1
			Card.new(:Club, :"8"),
			Card.new(:Heart, :"10"),
			Card.new(:Diamond, :"9"),
			Card.new(:Heart, :Ace),
			Card.new(:Spade, :Ace),
			Card.new(:Diamond, :Ace),
			# Player2
			Card.new(:Club, :"7"),
			Card.new(:Heart, :"7"),
			Card.new(:Diamond, :"8"),
			Card.new(:Heart, :"9"),
			Card.new(:Spade, :"7"),
			# TODO - Reverse in scope of constructor for encapsulation
			].reverse)
		@game.trump.should == :Spade
		@game.current_move.should == :player2
		verify_and_beat(:Club, :"7", :Club, :"8")
		verify_and_beat(:Heart, :"7", :Heart, :"10")
		verify_and_beat(:Diamond, :"8", :Diamond, :"9")
		verify_and_beat(:Heart, :"9", :Heart, :Ace)
		verify_and_beat(:Spade, :"7", :Spade, :Ace)
	end
end
