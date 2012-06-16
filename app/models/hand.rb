class Hand
  include ConstantsHelper::GameConstants

  attr_reader :cards

  delegate :delete, :last, :include?, :empty?, :size, :[], :to => :cards

  def initialize(cards = [])
    @cards = cards.dup
  end

  def draw(deck)
    cards_to_draw = 6 - size
    if cards_to_draw > 0
      add deck.draw(cards_to_draw)
    end
  end

  def none_of(suit)
    @cards.select { |it| it.suit != suit }
  end

  def all_of(suit)
    @cards.select { |it| it.suit == suit }
  end

  def smallest_of(suit)
    all_of(suit).min_by { |it| it.card_number }
  end

  def beats(card_to_beat, trump)
    @cards.select { |x| x.beats?(card_to_beat, trump) }.sort { |x, y|
      if (x.suit) == (y.suit)
        x.card_number <=> y.card_number
      elsif x.suit == trump
        1
      else
        -1
      end
    }
  end

  def put(card, table)
    return false unless include?(card)
    if table.put card
      delete(card)
    end
  end

  def beat(card, table)
    return false unless include?(card)
    if table.beat(card)
      delete(card)
    end
  end

  def take(table)
    @cards.push table.cards
    @cards.flatten!
    table.clear
  end

  private

  def add(cards)
    @cards.push cards
    @cards.flatten!
  end

end