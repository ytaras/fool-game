class Card
  include ActiveModel::Validations
  include ConstantsHelper::GameConstants
  validates_presence_of :card, :suit
  validates_inclusion_of :card, :in => CARDS
  validates_inclusion_of :suit, :in => SUITS
  attr_reader :suit, :card, :card_number

  def initialize(suit, card)
    @suit = suit
    @card = card
    @card_number = CARDS.index(@card)
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
