require 'spec_helper'

describe Card do
	describe "beat" do
		it "should beat lower card of own suit" do
			q = Card.new("Heart", "Queen")
			n = Card.new("Heart", "9")
			q.should be_beats(n)
			n.should_not be_beats(q)
		end

		it "should not beat card of other suit" do
			q = Card.new("Club", "Queen")
			n = Card.new("Heart", "9")
			q.should_not be_beats(n)
			n.should_not be_beats(q)
		end
	end
end
