class Card
  attr_reader :suit, :card, :card_number

  def initialize(suit, card)
    @suit = suit
    @card = card
    @card_number = Game::CARDS.index(@card)
  end

  def to_s
    "#{card} of #{suit}"
  end

  def ==(other)
    !other.nil? && @suit == other.suit && @card == other.card
  end

  def beats?(other, trump = nil)
    beats_same = suit == other.suit && card_number > other.card_number
    return beats_same if trump.nil? || suit != trump
    other.suit != trump || beats_same
  end
end
