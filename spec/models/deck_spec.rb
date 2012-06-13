require "rspec"

describe Deck do
  subject { Deck.new() }
  specify { subject.cards.should =~ Deck::SORTED_DECK }
  it "not equal to sorted deck" do
    subject.cards.should_not == Deck::SORTED_DECK
  end
  specify { subject.length.should == 36 }
  describe :trump do
    specify { subject.trump.should == subject.cards.last.suit }
    specify { subject.trump_card.should == subject.cards.last }
    it "should save trump even when deck is emptied" do
      subject.draw(36)
      subject.trump_card.should_not be_nil
    end
  end

  describe :draw do
    before(:each) do
      @first = subject.cards.first
      @drawn = subject.draw(6)
    end
    specify { @drawn.should have(6).items }
    specify { @drawn.should include(@first) }
    specify { subject.should have(30).cards }
  end

  context "is sorted" do
    subject { Deck.new(Deck::SORTED_DECK) }
    specify { should have(36).cards }
    specify { subject[0].should == Card.new(:Spade, :'6') }
  end

end