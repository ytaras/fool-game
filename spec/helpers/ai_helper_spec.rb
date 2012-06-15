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
    @game.table.should include(Card.new(:Heart, :"6"))
  end

  it "should beat with least available card" do
    def put_and_verify(p1suit, p1card, p2suit, p2card)
      put = Card.new(p1suit, p1card)
      beat = Card.new(p2suit, p2card)
      beat.should be_beats(put, @game.trump)
      @game.put(put)
      @game.table.cards.should include(put)
      @game.table.cards.should include(beat)
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
      @game.table.card_to_beat.should == Card.new(p2suit, p2card)
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
    @game.game.winner.should == :player2
  end

  describe AiHelper::AiGame do
    subject { @game }
    specify { @game.trump_card.should_not be_nil }
    specify { @game.deck.should == @game.game.deck.length }
    specify { @game.opponent.should == @game.game.player1_cards.size }
    specify { @game.player_move.should == (@game.current_move == :player1) }
  end
end
