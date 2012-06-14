class LogObserver
  delegate :clear, :to => :items
  attr_reader :items

  def initialize
    @items = []
  end

  def update(i)
    @items << i
  end
end
