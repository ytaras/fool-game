window.GameHelper = {
createCardDiv: (cardDef) ->
  cardDiv = GameHelper.createElement('div', 'card')
  cardDiv.dataset.card = cardDef.card
  cardDiv.dataset.suit = cardDef.suit
  cardSpan = GameHelper.createElement('span', 'card', cardDef.card)
  suitSpan = GameHelper.createElement('span', 'suit', cardDef.suit)
  cardDiv.appendChild(cardSpan)
  cardDiv.appendChild(suitSpan)
  return cardDiv

createElement: (name, aClass, text) ->
  elem = document.createElement(name)
  elem.className = aClass
  elem.text = text if text?
  return elem

loadData: (element, game) ->
  element.find('#trump').append GameHelper.createCardDiv(game.trumpCard)
}


