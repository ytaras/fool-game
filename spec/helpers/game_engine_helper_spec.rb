require 'spec_helper'

describe GameEngineHelper do
  describe "new game" do
  	it "deck contains all cards" do
  		game = helper.create_game
  		game.should have(36).deck_cards
  		game.deck_cards.should =~ helper.sorted_deck
  		game.deck_cards.should_not == helper.sorted_deck
  	end
  end
end
