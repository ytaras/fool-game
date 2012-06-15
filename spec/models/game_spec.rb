require 'spec_helper'

describe Game do
  before(:each) do
    @listener = LogObserver.new
    @game = Game.create_game :listener => @listener
  end

  shared_examples 'empty listener' do
    context do
      subject { @listener }
      specify { should be_empty }
    end
  end

  shared_examples "listener with events" do
    specify {
      if items.instance_of?(Array)
        @listener.items.should == items
      else
        @listener.items.should == [items]
      end
    }
  end

  subject { @game }

  describe "when game starts" do
    it_behaves_like 'listener with events' do
      let(:items) { {:game => @game, :event => :next_move} }
    end
    its(:table) { should be_empty }
    its(:discarded) { should be_empty }
    specify { should have(36 - 6 - 6).deck }
    specify { should have(6).player1_cards }
    specify { should have(6).player2_cards }

    context do
      before(:each) { @all_cards = @game.deck.cards + @game.player1.cards + @game.player2.cards }
      subject { @all_cards }
      specify { should =~ Game::SORTED_DECK }
      specify { should_not == Game::SORTED_DECK }
    end

    context 'when player2 should move' do
      before(:each) {
        start_deck = Game::SORTED_DECK.take(12)
        start_deck.push start_deck.shift
        @game = Game.create_game(start_deck)
      }
      its(:trump) { should == :Spade }
      its(:current_move) { should == :player2 }
    end

    context 'when player1 should move' do
      before(:each) {
        start_deck = Game::SORTED_DECK.take(12)
        start_deck.push start_deck.delete(Card.new(:Spade, :'7'))
        @game = Game.create_game(start_deck)
      }
      its(:trump) { should == :Spade }
      its(:current_move) { should == :player1 }
    end


    context 'with listener' do
      subject { @listener }
      specify { should have(1).items }
      specify { should include :game => @game, :event => :next_move }
    end

  end

  describe "when in game" do
    describe "when trying to put" do

      context "correct card" do
        before(:each) {
          @listener.clear
          @game.stub(:current_move => :player1)
          @card = @game.player1_cards[0]
          @result = @game.put(@card)
        }
        its(:player1_cards) { should_not include(@card) }
        its(:table) { should include(@card) }
        specify { @result.should be_true }
        it_behaves_like 'listener with events' do
          let(:items) { {:game => @game, :card => @card, :event => :put} }
        end
      end
      context "card not from hand" do
        before(:each) {
          @listener.clear
          @game.stub(:current_move => :player1)
          @card = @game.player2_cards[0]
          @result = @game.put(@card)
        }
        include_examples 'empty listener'
        specify { @result.should be_false }
        its(:table) { should be_empty }
      end
      context "not allowed card if" do
        before(:each) {
          @game = Game.create_game :deck => Array.new(Game::SORTED_DECK), :listener => @listener
          @first_card = @game.player2_cards.last
          @game.put(@first_card)
          @second_card = @game.player2_cards.last
          @listener.clear
          @result = @game.put(@second_card)
        }
        include_examples 'empty listener'
        # Verify precondition
        specify { @second_card.card.should_not == @first_card.card }

        its("table.cards") { should == [@first_card] }
        its(:player2_cards) { should include(@second_card) }
      end
    end

    describe "when trying to beat" do
      before(:each) do
        # TODO Move Game creation to helper
        start_deck = Array.new(Game::SORTED_DECK).take(12)
        start_deck.push start_deck.shift
        @game = Game.create_game :deck => start_deck, :listener => @listener
        @game.put(@game.player2_cards.last)
        @listener.clear
      end
      its(:current_move) { should == :player2 }

      context "correct card" do
        # Verifying preconditions conditions
        its(:trump) { should == :Spade }
        specify { subject.player1_cards[0].should be_beats(subject.table.card_to_beat) }

        context do
          before(:each) {
            @beating_card = @game.player1_cards.last
            @result = @game.beat(@beating_card)
          }
          specify { @result.should be_true }
          its(:player1_cards) { should_not include(@beating_card) }
          its(:table) { should include(@beating_card) }
          it_behaves_like 'listener with events' do
            let(:items) { {:game => @game, :card => @beating_card, :event => :beat} }
          end
        end
      end

      context "not existing card" do
        before(:each) {
          @beating_card = @game.player2_cards.last
          @result = @game.beat(@beating_card)
        }
        its('table.cards') { should_not include(@beating_card) }
        its(:player2_cards) { should include(@beating_card) }
        specify { @result.should be_false }
        include_examples 'empty listener'
      end

      context "not beating card" do
        before(:each) {
          start_deck = Array.new(Game::SORTED_DECK).take(12)
          @game = Game.create_game :deck => start_deck, :listener => @listener
          @game.put(@game.player2_cards.last)
          @listener.clear
          @saved_to_beat = @game.table.card_to_beat
          @beating = @game.player1_cards.last
        }
        specify { @beating.should_not be_beats(@saved_to_beat) }
        context do
          before(:each) { @result = @game.beat(@beating) }
          specify { @result.should be_false }
          its(:player1_cards) { should include(@beating) }
          its("table.card_to_beat") { should == @saved_to_beat }
          its('table.cards') { should_not include(@beating) }
          include_examples 'empty listener'
        end
      end
    end

    describe "end turn" do
      before(:each) do
        @game = Game.new(Array.new(Game::SORTED_DECK))
      end

      context "takes all cards from table to defending player" do
        before(:each) {
          @game.put(@game.player2_cards.last)
          @card_on_table = @game.table.card_to_beat
          @game.take
        }
        its(:player1_cards) { should include(@card_on_table) }
        its(:current_move) { should == :player2 }
        specify { should have(6).player2_cards }
        specify { should have(7).player1_cards }
        its(:table) { should be_empty }
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

