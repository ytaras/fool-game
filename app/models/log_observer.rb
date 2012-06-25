class LogObserver
  delegate :clear, :include?, :empty?, :to_a, :to => :items
  attr_reader :items

  def initialize
    @items = []
  end

  def update(i)
    i = i.dup
    unless i[:game].nil?
      game = i[:game]
      i[:game] = OpenStruct.new(:current_move => game.current_move)
    end
    @items << i
  end

  def watch_diff(game)
    raise 'block should be given' unless block_given?
    @items.clear
    game.add_observer self
    yield game
    game.delete_observer self
    res = diff
    puts @items.inspect
    puts res.inspect
    @items.clear
    res
  end

  def diff
    ret = {:table => {}, :hand => {}}

    def ret.add_card(subject, qualifier, card)
      self[subject] ||= {}
      self[subject][qualifier] ||= []
      if card.respond_to? :each
        card.each { |x| self[subject][qualifier] << x }
      else
        self[subject][qualifier] << card
      end
    end

    @items.each do |event|
      return unless event.is_a?(Hash)
      case event[:event]
        when :put
          unless event[:card].nil?
            ret.add_card(:table, :added, [[event[:card]]])
            ret.add_card(:hand, :removed, event[:card]) if event[:game].current_move == :player1
          end
        when :beat
          unless event[:card].nil?
            unless event[:game].current_move == :player1
              ret.add_card(:hand, :removed, event[:card])
            end
            ret[:table][:added] ||= [[]]
            ret[:table][:added].last[1] = event[:card]
          end
        when :take
          ret[:table][:added].clear unless ret[:table].nil? || ret[:table][:added].nil?
          ret.add_card(:table, :removed, event[:cards])
          if event[:game].current_move == :player2
            ret.add_card(:hand, :added, event[:cards])
          end
        when :next_move
          ret.add_card(:hand, :added, event[:cards]) if event[:cards]
        when :dismiss
          ret.add_card(:table, :removed, event[:cards]) if event[:cards]
        when :end
          puts "Event - #{event.inspect}"
          ret[:winner] = event[:winner]
      end
    end
    ret
  end

end
