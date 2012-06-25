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
      let(:items) { {:game => OpenStruct.new(:current_move => @game.current_move), :event => :next_move, :cards => @game.player1_cards} }
    end
    its(:table) { should be_empty }
    its(:discarded) { should be_empty }
    its(:winner) { should be_false }
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
      specify { should include :game => OpenStruct.new(:current_move => @game.current_move), :event => :next_move, :cards => @game.player1_cards }
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
          let(:items) { {:game => OpenStruct.new(:current_move => :player1), :card => @card, :event => :put} }
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
            let(:items) { {:game => OpenStruct.new(:current_move => :player2), :card => @beating_card, :event => :beat} }
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

    context "when take" do
      before(:each) {
        @game = Game.create_game :deck => Game::SORTED_DECK.dup, :listener => @listener
        @game.put(@game.player2_cards.last)
        @card_on_table = @game.table.card_to_beat
        @listener.clear
        @game.take
      }
      its(:player1_cards) { should include(@card_on_table) }
      its(:current_move) { should == :player2 }
      specify { should have(6).player2_cards }
      specify { should have(7).player1_cards }
      its(:table) { should be_empty }
      it_behaves_like 'listener with events' do
        let(:items) { [
            {:game => OpenStruct.new(:current_move => :player2), :cards => [@card_on_table], :event => :take, :player => :player1},
            {:game => OpenStruct.new(:current_move => :player2), :event => :next_move, :cards => []}
        ] }
      end
    end

    context "when pass" do
      before(:each) {
        start_deck = Array.new(Game::SORTED_DECK).take(14).reverse
        @game = Game.create_game :deck => start_deck, :listener => @listener
        @game.put(@game.player2_cards.last)
        @game.beat(@game.player1_cards.last)
        @table_cards = @game.table.cards
        @listener.clear
        @drawn = [@game.deck[0]]
        @game.pass
      }
      specify { should have(2).discarded }
      its(:table) { should be_empty }
      its(:current_move) { should == :player1 }
      specify { should have(6).player1_cards }
      specify { should have(6).player1_cards }
      its(:current_move) { should == :player1 }
      it_behaves_like 'listener with events' do
        let(:items) { [
            {:game => OpenStruct.new(:current_move => :player2), :cards => @table_cards, :event => :dismiss},
            {:game => OpenStruct.new(:current_move => :player1), :event => :next_move, :cards => @drawn}
        ] }
      end
    end

    context "when no cards are for any player" do
      before(:each) {
        start_deck = Array.new(Game::SORTED_DECK.take(7))
        start_deck.push start_deck.shift
        @game = Game.create_game :deck => start_deck, :listener => @listener
        @game.should have(1).player2_cards

        @game.put(@game.player2_cards.last)
        @listener.clear
        @table_cards = @game.table.cards
        @game.take
      }
      subject { @listener.diff }
      its([:winner]) { should == :player2 }
      it_behaves_like 'listener with events' do
        let(:items) { [
            {:game => OpenStruct.new(:current_move => :player2), :event => :take, :cards => @table_cards, :player => :player1},
            {:game => OpenStruct.new(:current_move => :player2), :event => :end, :winner => :player2}
        ] }
      end
    end

  end
end

