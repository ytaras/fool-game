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
      @game.trump.should == @game.deck_cards.last.suit
    end

    it "table is empty" do
      @game.table.should be_empty
    end

    it "discarded is empty" do
      @game.discarded.should be_empty
    end

    it "gives first turn to a gamer with lowest trump" do
      start_deck = Game::SORTED_DECK.take(12)
      start_deck.push start_deck.shift
      @game = Game.create_game(start_deck)
      @game.trump.should == :Spade
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

      it "dont allow to put card if not same card" do
        @game = Game.new(Array.new(Game::SORTED_DECK))
        first_card = @game.player2_cards.last
        @game.put(first_card)
        second_card = @game.player2_cards.last
        second_card.card.should_not == first_card.card
        @game.put(second_card)

        @game.table.keys.should == [first_card]
        @game.player2_cards.should include(second_card)
      end
    end

    describe "table" do
      it "allows only cards which are present" do
        @game.table[Card.new(:Heart, :Queen)] = nil
        @game.table[Card.new(:Heart, :"9")] = Card.new(:Club, :"8")
        @game.table[Card.new(:Heart, :"10")] = Card.new(:Heart, :"8")
        @game.available.should =~ [:Queen, :"9", :"8", :"10"]
      end
    end

    describe "beat" do
      before(:each) do
        @game = Game.new(Array.new(Game::SORTED_DECK))
      end

      it "player2 should start" do
        @game.current_move.should == :player2
      end

      it "player1 should be able to beat" do
        start_deck = Array.new(Game::SORTED_DECK).take(12)
        start_deck.push start_deck.shift
        @game = Game.new(start_deck)

        # Verifying starting conditions
        @game.trump.should == :Spade
        @game.player1_cards.first.should be_beats(@game.player2_cards.last)

        @game.put(@game.player2_cards.last)
        beating_card = @game.player1_cards.last
        @game.beat(beating_card)
        @game.player1_cards.should_not include(beating_card)
        @game.table.values.should include(beating_card)
      end

      it "does nothing on wrong params" do
        beating_card = @game.player1_cards.last
        @game.beat(beating_card)
        @game.table.should be_empty
        @game.player1_cards.should include(beating_card)
      end

      it "does nothing if card cant beat" do
        @game.put(@game.player2_cards.first)
        # Verify if we cant beat
        card_on_table = @game.table.keys.first
        beating_card = @game.player1_cards.last
        beating_card.should_not be_beats(card_on_table)
        @game.beat(beating_card)
        @game.player1_cards.should include(beating_card)
        @game.table[card_on_table].should == nil
      end
    end

    describe "end turn" do
      before(:each) do
        @game = Game.new(Array.new(Game::SORTED_DECK))
      end

      it "takes all cards from table to defending player" do
        @game.put(@game.player2_cards.last)
        card_on_table = @game.table.keys.first
        @game.take
        @game.player1_cards.should include(card_on_table)
        @game.current_move.should == :player2
        @game.should have(6).player2_cards
        @game.should have(7).player1_cards
        @game.table.should be_empty
      end

      it "puts all cards to discarded" do
        start_deck = Array.new(Game::SORTED_DECK).take(14).reverse
        @game = Game.new(start_deck)
        @game.player1_cards.last.should be_beats(@game.player2_cards.last)

        @game.put(@game.player2_cards.last)
        @game.beat(@game.player1_cards.last)
        @game.pass
        @game.should have(2).discarded
        @game.table.should be_empty
        @game.current_move.should == :player1
        @game.should have(6).player1_cards
        @game.should have(6).player2_cards
      end
    end

    describe "end game" do
      it "game winner should be nil at start" do
        @game.winner.should == nil
      end

      it "game ends when no cards are for any player" do
        start_deck = Array.new(Game::SORTED_DECK.take(7))
        start_deck.push start_deck.shift
        @game = Game.new(start_deck)
        @game.should have(1).player2_cards

        @game.put(@game.player2_cards.last)
        @game.take

        @game.winner.should == :player2
      end

    end
  end
end
