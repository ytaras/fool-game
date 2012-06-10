require 'spec_helper'
#TODO Instead of creating AiGame which wraps Game it should be pluggable game with teams 
# and AI < Team and Human < Team

describe AiHelper do
  before(:each) do
    @game = helper.create_game
  end
  it "creates AI game" do
    @game.should_not == nil
  end

  it "throws least not-trump card on a table if starts" do
    @game = helper.create_game(Array.new(Game::SORTED_DECK))
    @game.current_move.should == :player2
    @game.table.should include([Card.new(:Heart, :"6")])
  end

  it "should beat with least available card" do
    def put_and_verify(p1suit, p1card, p2suit, p2card)
      put = Card.new(p1suit, p1card)
      beat = Card.new(p2suit, p2card)
      beat.should be_beats(put, @game.trump)
      @game.put(put)
      @game.table.map { |x| x[1] }.should include(beat)
    end

    start_deck = [
        # Player1
        Card.new(:Club, :"7"),
        Card.new(:Heart, :"7"),
        Card.new(:Diamond, :"8"),
        Card.new(:Heart, :"9"),
        Card.new(:Diamond, :"7"),
        Card.new(:Club, :"10"),

        # Player2
        Card.new(:Diamond, :"9"),
        Card.new(:Diamond, :Ace),
        Card.new(:Club, :"8"),
        Card.new(:Heart, :"10"),
        Card.new(:Spade, :Ace),
        Card.new(:Diamond, :"10"),
    ]
    @game = helper.create_game(start_deck)
    put_and_verify(:Club, :"7", :Club, :"8")
    put_and_verify(:Heart, :"7", :Heart, :"10")
    put_and_verify(:Diamond, :"8", :Diamond, :"9")
    put_and_verify(:Heart, :"9", :Diamond, :"10")
    put_and_verify(:Club, :"10", :Diamond, :Ace)
    @game.put(Card.new(:Diamond, :"7"))
    @game.table.should be_empty
  end

  it "should throw same card if can" do
    def verify_and_beat(p2suit, p2card, p1suit, p1card)
      @game.table.map { |x| x[0] }.should include(Card.new(p2suit, p2card))
      @game.beat(Card.new(p1suit, p1card))
    end

    start_deck = [
        # Player1
        Card.new(:Club, :"8"),
        Card.new(:Heart, :"10"),
        Card.new(:Diamond, :"9"),
        Card.new(:Heart, :Ace),
        Card.new(:Spade, :Ace),
        Card.new(:Diamond, :Ace),
        # Player2
        Card.new(:Club, :"7"),
        Card.new(:Heart, :"7"),
        Card.new(:Diamond, :"8"),
        Card.new(:Heart, :"9"),
        Card.new(:Spade, :"7"),
    ]
    @game = helper.create_game(start_deck)
    @game.trump.should == :Spade
    @game.current_move.should == :player2
    verify_and_beat(:Club, :"7", :Club, :"8")
    verify_and_beat(:Heart, :"7", :Heart, :"10")
    verify_and_beat(:Diamond, :"8", :Diamond, :"9")
    verify_and_beat(:Heart, :"9", :Heart, :Ace)
    verify_and_beat(:Spade, :"7", :Spade, :Ace)
    @game.current_move.should == :player1
  end

  describe AiHelper::AiGame do
    it "shows trump card" do
      @game.trump_card.should_not be_nil
    end

    it "knows amount of cards in deck" do
      @game.deck.should == @game.game.deck_cards.size
    end
  end
end
