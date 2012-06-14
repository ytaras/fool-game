require 'spec_helper'

describe Hand do
  subject { Hand.new(Hand::SORTED_DECK.take(6)) }
  specify { subject.should have(6).cards }
  specify { subject.size.should == 6 }
  specify { subject[0].should == Hand::SORTED_DECK[0] }

  specify { subject.last.should == subject.cards.last }

  specify { subject.delete(subject[0]).should_not be_nil }
  specify {
    lambda { subject.delete(subject[0]) }.should change { subject.size }.from(6).to(5)
  }
  specify { should include(subject[0]) }


  context "empty hand" do
    subject { Hand.new }
    specify { subject.should be_empty }
  end

  context 'when put on table' do
    before(:each) {
      @table = Table.new
      @table.trump = :Heart
      @result = subject.put(subject[0], @table)
    }
    specify { @result.should be_true }
    specify { @table.should have(1).cards }
    specify { should have(5).cards }
    specify { lambda {
      subject.put(Card.new(:Clubs, :'9'), @table)
    }.should_not change { @table.cards } }
  end

  context 'when attacking card present' do
    before(:each) {
      @hand1 = Hand.new([
                            Card.new(:Hearts, :'10'),
                        ])
      @hand2 = Hand.new([
                            Card.new(:Hearts, :Jack),
                            Card.new(:Spade, :Ace),
                        ])
      @table = Table.new
      @hand1.put(@hand1.cards.first, @table)
    }

    context 'when beat with correct card' do
      before(:each) {
        @beat_card = @hand2.cards.first
        @result = @hand2.beat(@beat_card, @table)
      }
      specify { @table.should have(2).cards }
      specify { @result.should be_true }
      specify { @hand2.should_not include(@beat_card) }
    end
    context 'when beat with incorrect card' do
      before(:each) {
        @beat_card = @hand2.cards[1]
        @result = @hand2.beat(@beat_card, @table)
      }
      specify { @table.should have(1).cards }
      specify { @result.should be_false }
      specify { @hand2.should include(@beat_card) }

    end
  end

  context do
    subject { Hand.new([
                           Card.new(:Hearts, :'10'),
                           Card.new(:Spade, :'8'),
                           Card.new(:Club, :'9'),
                           Card.new(:Club, :'6')
                       ]) }
    describe :smallest_of do
      specify { subject.smallest_of(:Hearts).should == Card.new(:Hearts, :'10') }
      specify { subject.smallest_of(:Club).should == Card.new(:Club, :'6') }
      specify { subject.smallest_of(:Spade).should == Card.new(:Spade, :'8') }
      specify { subject.smallest_of(:Diamond).should be_nil }
    end
    describe :all_of do
      specify { subject.all_of(:Hearts).should have(1).items }
      specify { subject.all_of(:Club).should have(2).items }
      specify { subject.all_of(:Spade).should have(1).items }
      specify { subject.all_of(:Diamond).should be_empty }
    end
    describe :none_of do
      specify { subject.none_of(:Hearts).should have(3).items }
      specify { subject.none_of(:Club).should have(2).items }
      specify { subject.none_of(:Spade).should have(3).items }
      specify { subject.none_of(:Diamond).should have(4).items }
    end

    describe :beats do
      specify { subject.beats(Card.new(:Hearts, :'7'), :Spade).should have(2).items }
      specify { subject.beats(Card.new(:Hearts, :'7'), :Club).should have(3).items }
      specify { subject.beats(Card.new(:Hearts, :'7'), :Hearts).should have(1).items }
      specify { subject.beats(Card.new(:Hearts, :Jack), :Hearts).should be_empty }
    end

    describe :draw do
      context "when enough cards" do
        before(:each) {
          @deck = Deck.new(Deck::SORTED_DECK.take(3))
          subject.draw(@deck)
        }
        specify { should have(6).cards }
        specify { @deck.should have(1).cards }
      end
      context "when no enough cards" do
        before(:each) {
          @deck = Deck.new(Deck::SORTED_DECK.take(1))
          subject.draw(@deck)
        }
        specify { should have(5).cards }
        specify { @deck.should have(0).cards }
      end
    end

    describe :take do
      before(:each) {
        @table = Table.new
        @table.put(Deck::SORTED_DECK.take(5))
        subject.take(@table)
      }

      specify { should have(4 + 5).cards }
      specify { @table.should be_empty }
    end
  end

end
