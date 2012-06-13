class Deck
  include ConstantsHelper::GameConstants

  delegate :items, :[], :length, :to => :cards
  attr_reader :cards, :trump_card

  def initialize(cards = SORTED_DECK.shuffle)
    @cards = cards
    @trump_card = @cards.last
  end

  def trump
    trump_card.suit
  end

  def draw(n)
    @cards.shift(n)
  end
end