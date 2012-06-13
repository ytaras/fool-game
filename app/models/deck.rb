class Deck
  include ConstantsHelper::GameConstants

  delegate :items, :[], :to => :cards
  attr_reader :cards

  def initialize(cards = SORTED_DECK.shuffle)
    @cards = cards
  end
end