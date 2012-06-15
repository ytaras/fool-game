class LogObserver
  delegate :clear, :include?, :to => :items
  attr_reader :items

  def initialize
    @items = []
  end

  def update(i)
    @items << i
  end
end
