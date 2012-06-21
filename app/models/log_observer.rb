class LogObserver
  delegate :clear, :include?, :empty?, :to_a, :to => :items
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
    ret = {:table => {}, :hand => {}}
    @items.each do |event|
      return unless event.is_a?(Hash)
      case event[:event]
        when :put
          ret[:table][:added] ||= []
          ret[:hand][:removed] ||= []
          unless event[:card].nil?
            ret[:table][:added] << [event[:card]]
            ret[:hand][:removed] << event[:card] if event[:game].current_move == :player1
          end
        when :beat
          ret[:table][:added] ||= [[]]
          ret[:hand][:removed] ||= []
          unless event[:card].nil?
            ret[:hand][:removed] << event[:card] unless event[:game].current_move == :player1
            ret[:table][:added].last[1] = event[:card]
          end
        when :take
          ret[:table][:added].clear unless ret[:table][:added].nil?
          ret[:table][:removed] = event[:cards]
      end
    end
    ret
  end
end
