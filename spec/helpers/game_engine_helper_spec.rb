require 'spec_helper'

describe GameEngineHelper do
  describe "new game" do
  	it "deck contains all cards" do
  		game = helper.create_game
  		game.should have(36).deck_cards
  	end
  end
end
