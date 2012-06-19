node :cards do
  @game.player1_cards.map do |card|
    partial("game/card", :object => card)
  end
end
node :table do
  @game.table.stacks.map do |stack|
    # TODO Learn RABL collections
    stack.map do |card|
      partial("game/card", :object => card)
    end
  end
end
node :deck do
  @game.deck.size
end
node :myMove do
  @game.current_move == :player1
end
node :opponent do
  @game.player2_cards.size
end
node :trumpCard do
  partial("game/card", :object => @game.trump_card)
end
unless @changes.nil?
  child @changes => :changes do

  end
end