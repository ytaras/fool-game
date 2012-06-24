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

removeCards: (parent, removed) ->
  $.each removed, (i, card) ->
    $(parent + ' .' + GameHelper.class_name(card) + '.card').remove()

addCards: (parent, added) ->
  parentE = $(parent)
  $.each added, (i, card) ->
    el = GameHelper.createCardDiv(card)
    parentE.append el
    $(el).click((event) -> GameHelper.card_click event.target)

applyChanges: (result) ->
  window.game = result.game
  if result.changes?
    if result.changes.winner?
      alertStr = if(result.winner) then 'You win' else 'You loose'
      alert alertStr
      location.reload()
    if result.changes.table?
      @addToTable(result.changes.table.added) if result.changes.table.added?
      @removeCards('#table', result.changes.table.removed) if result.changes.table.removed?
      $('#table .cards-stack:empty').remove()
    if result.changes.hand?
      @removeCards('#hand', result.changes.hand.removed) if result.changes.hand.removed?
      console.log result.changes.hand
      @addCards('#hand', result.changes.hand.added) if result.changes.hand.added?
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
    error: (result, status, errorThrown) ->
      console.log result

take: ->
  $.ajax
    "type": "POST"
    "url": "/game/move"
    "data":
      move: 'take'
    success: (result) ->
      GameHelper.applyChanges(result)
    error: (result, status, errorThrown) ->
      console.log result
pass: ->
  $.ajax
    "type": "POST"
    "url": "/game/move"
    "data":
      move: 'pass'
    success: (result) ->
      GameHelper.applyChanges(result)
    error: (result, status, errorThrown) ->
      console.log result
installHandlers: ->
  $('#hand .card').click((event) -> GameHelper.card_click event.target)
  $('.take').click((event) -> GameHelper.take())
  $('.pass').click((event) -> GameHelper.pass())

visible: (element, value) ->
  $(element)[if value then 'show' else 'hide']()
class_name: (card) ->
  ('cards-' + card.suit + 's' + (if card.card == '10' then '10' else card.card[0])).toLowerCase()
}

$(document).ready () ->
  GameHelper.loadData window.gon.game if window.gon?
