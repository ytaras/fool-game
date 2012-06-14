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

  describe :add do
    context "add one item" do
      before(:each) { subject.add(Hand::SORTED_DECK.last) }
      specify { subject.should have(7).items }
      specify { subject.cards.last.should == Deck::SORTED_DECK.last }
    end
    context "add few item" do
      before(:each) { subject.add(Hand::SORTED_DECK.last(3)) }
      specify { subject.should have(9).items }
      specify { subject.cards.last(3).should == Deck::SORTED_DECK.last(3) }
      specify { subject.cards.first(6).should == Deck::SORTED_DECK.first(6) }
    end
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
  end

end
