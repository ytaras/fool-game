class LogObserver
  delegate :clear, :include?, :empty?, :to => :items
  attr_reader :items

  def initialize
    @items = []
  end

  def update(i)
    @items << i
  end

  def diff
    ret = {:table => {}}
    @items.each do |event|
      return unless event.is_a?(Hash)
      case event[:action]
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
