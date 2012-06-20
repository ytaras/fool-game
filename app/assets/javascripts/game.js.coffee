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

addToTable: (added) ->
  $.each added, (i, stack) ->
    if(stack.length == 1)
      stackDiv = GameHelper.createElement 'div', 'cards-stack'
      $(stackDiv).append GameHelper.createCardDiv(stack[0], 'attack-card')
      $('#table').append stackDiv
    else if(stack.length == 2)
      if(stack[0]?)
        stackDiv = GameHelper.createElement 'div', 'cards-stack'
        $(stackDiv).append GameHelper.createCardDiv(stack[0], 'attack-card')
        $(stackDiv).append GameHelper.createCardDiv(stack[1], 'defense-card')
        $('#table').append stackDiv
      else
        lastStack = $('#table .cards-stack').last()
        lastStack.append GameHelper.createCardDiv(stack[1], "defense-card")
    else
      console.log "Error - expected length 1 or 2 " + stack

removeFromTable: (removed) ->
  $.each removed, (i, card) ->
    $('#table .' + GameHelper.class_name(card) + '.card').remove()

applyChanges: (result) ->
  window.game = result.game
  if result.changes? && result.changes.table?
    @addToTable(result.changes.table.added) if result.changes.table.added?
    @removeFromTable(result.changes.table.removed) if result.changes.table.removed?
    @showOpponentCards(game.opponent)

showOpponentCards: (cards) ->
  opponentElem = $('#opponent_cards')
  currentCards = $('#opponent_cards .card')
  if currentCards.length < cards
    for n in [(currentCards.length)...cards]
      opponentElem.append GameHelper.createElement("div", "card cards-backblue-1")
  else if currentCards.length > cards
    currentCards.slice(0, currentCards.length - cards).remove()


loadData: (game) ->
  window.game = game
  $('#trump').append GameHelper.createCardDiv(game.trumpCard)
  GameHelper.visible('#deck', game.deck > 1)
  GameHelper.visible('#trump', game.deck > 0)
  handElem = $('#hand')
  $.each game.cards, (i, card) ->
    handElem.append GameHelper.createCardDiv card
  tableElem = $('#table')
  $.each game.table, (i, cards) ->
    stack = GameHelper.createElement("div", "cards-stack")
    $(stack).append GameHelper.createCardDiv(cards[0], "attack-card")
    $(stack).append GameHelper.createCardDiv(cards[1], "defense-card") if cards.length > 1
    tableElem.append stack
  @showOpponentCards(game.opponent)
  @installHandlers()

card_click: (card) ->
  if card instanceof HTMLElement
    card = {"card": card.dataset.card, "suit": card.dataset.suit}
  # TODO Error handling
  $.ajax
    "type": "POST"
    "url": "/game/move"
    "data":
      move: (if game.myMove then 'put' else 'beat')
      card: card
    success: (result) ->
      GameHelper.applyChanges(result)
      console.log(result)
    error: (result, status, errorThrown) ->
      console.log result

take: ->
  $.ajax
    "type": "POST"
    "url": "/game/move"
    "data":
      move: 'take'
    success: (result) ->
      #      console.log(result)
    error: (result, status, errorThrown) ->
      console.log result
pass: ->
  $.ajax
    "type": "POST"
    "url": "/game/move"
    "data":
      move: 'pass'
    success: (result) ->
      #      console.log(result)
    error: (result, status, errorThrown) ->
      console.log result
installHandlers: ->
  $('#hand .card').click((event) -> GameHelper.card_click event.target)
  $('.take').click((event) -> GameHelper.take)
  $('.pass').click((event) -> GameHelper.pass)

visible: (element, value) ->
  $(element)[if value then 'show' else 'hide']()
class_name: (card) ->
  ('cards-' + card.suit + 's' + (if card.card == '10' then '10' else card.card[0])).toLowerCase()
}

$(document).ready () ->
  GameHelper.loadData window.gon.game if window.gon?
