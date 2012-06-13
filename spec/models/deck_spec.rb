require "rspec"

describe Deck do
  context "is sorted" do
    subject { Deck.new(Deck::SORTED_DECK) }
    specify { should have(36).cards }
    specify { subject[0].should == Card.new(:Spade, :'6') }
  end

  context "is unsorted" do
    subject { Deck.new() }
    specify { subject.cards.should =~ Deck::SORTED_DECK }
    it "not equal to sorted deck" do
      subject.cards.should_not == Deck::SORTED_DECK
    end
  end

end