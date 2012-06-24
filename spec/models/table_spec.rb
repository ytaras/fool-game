require 'spec_helper'

describe Table do
  subject { Table.new }
  before(:each) { subject.trump = Table::SUITS.last }
  specify { should be_empty }


  context :attack do
    specify { subject.move.should == :attack }
    specify { should have(0).cards }
    specify { subject.stacks_count == 0 }
    specify { subject.beat(Card.new(:Heart, :'6')).should be_false }
    describe :put do
      specify { subject.put(Table::SORTED_DECK.first).should be_true }
    end
  end

  context :defense do
    before(:each) { subject.put(Table::SORTED_DECK.first) }
    specify { subject.move.should == :defense }
    specify { should have(1).cards }
    specify { subject.stacks_count == 1 }
    specify { should include(Table::SORTED_DECK.first) }
    specify { subject.beat(Table::SORTED_DECK[10]).should be_false }
    context "when trying to attack during defense" do
      before(:each) { @result = subject.put(Table::SORTED_DECK[1]) }
      specify { @result.should be_false }
      specify { should have(1).cards }
      specify { subject.stacks_count == 1 }
      specify { should_not include(Table::SORTED_DECK[1]) }
    end
    context :beat do
      before(:each) { @result = subject.beat(Table::SORTED_DECK[1]) }
      specify { @result.should be_true }
      specify { should have(2).cards }
      specify { subject.stacks_count == 1 }
      specify { should include(Table::SORTED_DECK[1]) }
      specify { subject.move.should == :attack }
      specify { subject.put(Table::SORTED_DECK[2]).should be_false }
      specify { subject.put(Card.new(:Heart, subject.available.first)).should be_true }
    end
  end

  describe :clear do
    before(:each) {
      subject.put(Table::SORTED_DECK[0])
      subject.beat(Table::SORTED_DECK[1])
      subject.put(Table::SORTED_DECK[0])
      subject.clear
    }
    specify { should be_empty }
    its(:move) { should == :attack }
  end

  describe :available do
    specify {
      subject.put Card.new(:Heart, :"7")
      subject.beat Card.new(:Heart, :"8")
      subject.put Card.new(:Club, :"8")
      subject.beat Card.new(:Club, :"9")
      subject.available.should =~ [:"7", :"8", :'9']
    }

  end
end
