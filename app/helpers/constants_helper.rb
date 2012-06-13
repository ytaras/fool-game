module ConstantsHelper
  module GameConstants
    SUITS = %w(Spade Heart Diamond Club).map { |e| e.to_sym }
    CARDS = %w(6 7 8 9 10 Jack Queen King Ace).map { |e| e.to_sym }

    SORTED_DECK = Array.new
    SUITS.each { |suit| CARDS.each { |card| SORTED_DECK.push Card.new(suit, card) } }
    SORTED_DECK.freeze
  end
end