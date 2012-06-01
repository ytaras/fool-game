require 'spec_helper'

describe Game do
	before(:each) do
		@game = Game.create_game
	end

	describe "game start" do
		it "deck contains all cards" do
	  		@game.should have(36 - 6 - 6).deck_cards
	  		all_cards = @game.deck_cards + @game.player1_cards + @game.player2_cards
	  		all_cards.should =~ Game::SORTED_DECK
	  		all_cards.should_not == Game::SORTED_DECK
	  	end

	  	it "knows the trump" do
	  		@game.trump.should == @game.deck_cards.first.suit
	  	end

	  	it "table is empty" do
			@game.should have(0).table
		end

		it "gives first turn to a gamer with lowest trump" do
			start_deck = Game::CARDS.map {|it| Card.new(:heart, it)}
			@game = Game.create_game(start_deck)
			@game.next_move
			@game.trump.should == :heart
			@game.player2_cards.map { |it| it.card }.should include("6")
			@game.current_move.should == :player2
		end

		it "each player 6 cards each on start" do
			@game.should have(6).player1_cards
			@game.should have(6).player2_cards
		end
	end

	describe "in game" do
		describe "put" do
			it "allow to put card on table" do
				@game.stub(:current_move => :player1)
				card = @game.player1_cards.first
				@game.put(card)	
				@game.player1_cards.should_not include(card)
				@game.table.should include({card => nil})
			end

			it "does nothing on wrong card" do
				@game.stub(:current_move => :player1)
				card = @game.player2_cards.first
				@game.put(card)		
				@game.table.should be_empty
			end
		end
	end
end
