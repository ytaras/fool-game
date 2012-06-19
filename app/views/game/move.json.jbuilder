Jbuilder.encode do |json|
  json.game do |json|
    json.cards @game.player1_cards, :suit, :card
    json.table @game.table.stacks do |json, stack|
      json.array!(stack) do |json, card|
        json.suit card.suit
        json.card card.card
      end
    end
    json.trumpCard @game.trump_card, :suit, :card
    json.myMove @game.current_move == :player1
    json.opponent @game.player2_cards.size
    json.deck @game.deck.size
  end
end