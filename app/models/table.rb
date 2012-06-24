class Table
  include ConstantsHelper::GameConstants

  delegate :empty?, :include?, :to => :cards
  attr_reader :move, :stacks
  attr_accessor :trump

  def initialize
    @stacks = []
    @move = :attack
  end

  def available
    @stacks.flatten.map { |e| e.card }.uniq
  end

  def put(card)
    return false unless move == :attack
    return false unless empty? || available.include?(card.card)
    @stacks << [card]
    @move = :defense
  end

  def beat(card)
    return false unless move == :defense
    return false unless card.beats?(card_to_beat, trump)
    @stacks.last << card
    @move = :attack
  end

  def cards
    @stacks.flatten
  end

  def stacks_count
    @stacks.size
  end

  def card_to_beat
    return nil if @stacks.empty?
    @stacks.last[0]
  end

  def clear
    @move = :attack
    @stacks.clear
  end
end
