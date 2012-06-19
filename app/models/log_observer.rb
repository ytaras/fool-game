class LogObserver
  delegate :clear, :include?, :empty?, :to => :items
  attr_reader :items

  def initialize
    @items = []
  end

  def update(i)
    @items << i
  end

  def watch_diff(game)
    raise 'block should be given' unless block_given?
    @items.clear
    game.add_observer self
    yield game
    game.delete_observer self
    res = diff
    @items.clear
    res
  end

  def diff
    ret = {:table => {}}
    @items.each do |event|
      return unless event.is_a?(Hash)
      case event[:event]
        when :put
          ret[:table][:added] ||= []
          ret[:table][:added] << [event[:card]] unless event[:card].nil?
        when :beat
          ret[:table][:added] ||= [[]]
          ret[:table][:added].last[1] = event[:card] unless event[:card].nil?
        when :take
          ret[:table][:added].clear unless ret[:table][:added].nil?
          ret[:table][:removed] = event[:cards]
      end
    end
    ret
  end
end
