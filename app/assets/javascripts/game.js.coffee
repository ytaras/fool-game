window.GameHelper = {
createCardDiv: (cardDef, style = "") ->
  cardDiv = GameHelper.createElement('div', 'card ' + GameHelper.class_name(cardDef) + " " + style)
  cardDiv.dataset.card = cardDef.card
  cardDiv.dataset.suit = cardDef.suit
  return cardDiv

createElement: (name, aClass, text) ->
  elem = document.createElement(name)
  elem.className = aClass
  $(elem).text(text) if text?
  return elem

loadData: (element, game) ->
  element.find('#trump').append GameHelper.createCardDiv(game.trumpCard)
  GameHelper.visible('#deck', game.deck > 1)
  GameHelper.visible('#trump', game.deck > 0)
  handElem = element.find('#hand')
  $.each game.cards, (i, card) ->
    handElem.append GameHelper.createCardDiv card
  tableElem = element.find('#table')
  $.each game.table, (i, cards) ->
    stack = GameHelper.createElement("div", "cards-stack")
    $(stack).append GameHelper.createCardDiv(cards[0], "attack-card")
    $(stack).append GameHelper.createCardDiv(cards[1], "defense-card") if cards.length > 1
    tableElem.append stack
  opponentElem = element.find('#opponent_cards')
  for n in [1..game.opponent]
    opponentElem.append GameHelper.createElement("div", "card cards-backblue-1")


visible: (element, value) ->
  $(element)[if value then 'show' else 'hide']()
class_name: (card) ->
  ('cards-' + card.suit + 's' + (if card.card == '10' then '10' else card.card[0])).toLowerCase()
}

$(document).ready () ->
  GameHelper.loadData($('#gamefield'), window.gon.game) if window.gon?