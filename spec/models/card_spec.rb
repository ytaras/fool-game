require 'spec_helper'

describe Card do
  describe "beat" do
    it "should beat lower card of own suit" do
      q = Card.new(:Heart, :Queen)
      n = Card.new(:Heart, :"9")
      q.should be_beats(n)
      n.should_not be_beats(q)
    end

    it "should not beat card of other suit" do
      q = Card.new(:Club, :Queen)
      n = Card.new(:Heart, :"9")
      q.should_not be_beats(n)
      n.should_not be_beats(q)
    end

    it "should beat card if it's trump" do
      q = Card.new(:Club, :Queen)
      n = Card.new(:Heart, :"9")
      t = Card.new(:Heart, :"10")
      q.should be_beats(n, :Club)
      t.should be_beats(n, :Heart)
      n.should_not be_beats(t, :Heart)
    end
  end

  describe :valid do
    describe "invalid card" do

      before(:all) do
        @card = Card.new(:A, :B)
      end
      subject { @card }
      specify { should_not be_valid }
      describe do
        subject { @card.errors.messages }
        specify { should have_key(:card) }
        specify { should have_key(:suit) }
      end
    end

    describe "valid card" do
      subject { Card.new(:Heart, :"10") }
      specify { should be_valid }
    end
  end
end
