# TODO Duplication with play
object @game => :game
attributes :table, :deck, :opponent
node :trumpCard do
  partial("game/card", :object => @game.trump_card)
end
node :cards do
  @game.player1_cards.map do |card|
    partial("game/card", :object => card)
  end
end
