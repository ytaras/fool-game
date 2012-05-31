require 'spec_helper'

describe GameEngineHelper do
	before(:each) do
		@game = helper.create_game
	end
  describe "new game" do
  	describe "deck" do
	  	it "deck contains all cards" do
	  		@game.should have(36).deck_cards
	  		@game.deck_cards.should =~ helper.sorted_deck
	  		@game.deck_cards.should_not == helper.sorted_deck
	  	end
	  end

  	describe "players" do
  		it "not have cards on start" do
  			@game.should have(0).player1_cards
  			@game.should have(0).player2_cards
  		end

  		it "have 6 cards each after draw" do
  			@game.next_move
  			@game.should have(6).player1_cards
  			@game.should have(6).player2_cards
  		end
  	end
  end
end
