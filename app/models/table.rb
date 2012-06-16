class Table
  include ConstantsHelper::GameConstants

  delegate :empty?, :include?, :to => :cards
  delegate :clear, :to => :@table
  attr_reader :move
  attr_accessor :trump

  def initialize
    @table = []
    @move = :attack
  end

  def available
    @table.flatten.map { |e| e.card }.uniq
  end

  def put(card)
    return false unless move == :attack
    return false unless empty? || available.include?(card.card)
    @table << [card]
    @move = :defense
  end

  def beat(card)
    return false unless move == :defense
    return false unless card.beats?(card_to_beat, trump)
    @table.last << card
    @move = :attack
  end

  def cards
    @table.flatten
  end

  def stacks_count
    @table.size
  end

  def card_to_beat
    return nil if @table.empty?
    @table.last[0]
  end

end
