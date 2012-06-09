window.GameHelper = {
createCardDiv: (cardDef) ->
  cardDiv = GameHelper.createElement('div', 'card')
  cardDiv.dataset.card = cardDef.card
  cardDiv.dataset.suit = cardDef.suit
  cardSpan = GameHelper.createElement('span', 'card_value', cardDef.card)
  suitSpan = GameHelper.createElement('span', 'suit', cardDef.suit)
  cardDiv.appendChild(cardSpan)
  cardDiv.innerHTML += ' of '
  cardDiv.appendChild(suitSpan)
  return cardDiv

createElement: (name, aClass, text) ->
  elem = document.createElement(name)
  elem.className = aClass
  $(elem).text(text) if text?
  return elem

loadData: (element, game) ->
  element.find('#trump').append GameHelper.createCardDiv(game.trumpCard)
  if game.deck
    element.find('#deck').show()
  else
    element.find('#deck').hide()
  handElem = element.find('#hand')
  $.each game.cards, (i, card) ->
    handElem.append GameHelper.createCardDiv card
}

$(document).ready () ->
  GameHelper.loadData($('#gamefield'), window.gon.game) if window.gon?