require 'spec_helper'

describe GameEngineHelper do

	before(:each) do
		@game = helper.create_game
	end
  	describe "deck" do
	  	it "deck contains all cards" do
	  		@game.should have(36 - 6 - 6).deck_cards
	  		all_cards = @game.deck_cards + @game.player1_cards + @game.player2_cards
	  		all_cards.should =~ helper.sorted_deck
	  		all_cards.should_not == helper.sorted_deck
	  	end

	  	it "knows the trump" do
	  		@game.trump.should == @game.deck_cards.first.suit
	  	end
	end

	describe "game" do
		it "gives first turn to a gamer with lowest trump" do
			start_deck = GameEngineHelper::CARDS.map {|it| GameEngineHelper::Card.new(:heart, it)}
			@game = helper.create_game(start_deck)
			@game.next_move
			@game.trump.should == :heart
			@game.player2_cards.map { |it| it.card }.should include("6")
			@game.current_move.should == :player2
		end
	end

  	describe "players" do
		it "have 6 cards each on start" do
			@game.should have(6).player1_cards
			@game.should have(6).player2_cards
		end
	end
end
