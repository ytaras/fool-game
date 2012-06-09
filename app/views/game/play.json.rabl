object @game => :game
attributes :table, :deck
node :trump do
  partial("game/card", :object => @game.trump_card)
end
node :cards do
  @game.player1_cards.map do |card|
    partial("game/card", :object => card)
  end
end
