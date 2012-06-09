window.GameHelper = {
createCardDiv: (cardDef) ->
  cardDiv = GameHelper.createElement('div', 'card ' + GameHelper.class_name(cardDef))
  cardDiv.dataset.card = cardDef.card
  cardDiv.dataset.suit = cardDef.suit
  # TODO Use JQuery to create elems
#  $(cardDiv).addClass()
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

visible: (element, value) ->
  $(element)[if value then 'show' else 'hide']()
class_name: (card) ->
  ('cards-' + card.suit + 's' + (if card.card == '10' then '10' else card.card[0])).toLowerCase()
}

$(document).ready () ->
  GameHelper.loadData($('#gamefield'), window.gon.game) if window.gon?