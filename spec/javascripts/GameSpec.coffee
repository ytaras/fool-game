describe 'GameHelper', ->
  it "creates card div from card spec", ->
    card = {"card": "6", "suit": "Heart"}
    div = $(GameHelper.createCardDiv card)
    expect(div).toHaveClass 'card'
    expect(div).toHaveClass 'cards-hearts6'
    expect(div).toHaveData('card', '6')
    expect(div).toHaveData('suit', 'Heart')

  describe "load game", ->
    beforeEach ->
      jasmine.getFixtures().load('game.html')
      @game =
        trumpCard:
          suit: 'Heart'
          card: 'Ace'
        deck: 2
        cards: [
          {suit: 'Heart', card: '6'}
          {suit: 'Spade', card: '7'}
        ]
        table: [
          [
            {suit: 'Spade', card: '8'},
            {suit: 'Spade', card: '9'}
          ]
          [
            {suit: 'Heart', card: '9'}
          ]
        ]
      GameHelper.loadData($('#gamefield'), @game)
    it "creates trump as a card", ->
      expect($('#trump')).toContain('div.card')
    it "shows deck", ->
      expect($('#deck')).toBeVisible()
    it "shows hand", ->
      expect($('#hand div.card').length).toBe(2)
    it "shows only trump if 1 card in deck", ->
      jasmine.getFixtures().load('game.html')
      @game.deck = 1
      GameHelper.loadData($('#gamefield'), @game)
      expect($('#trump')).toBeVisible()
      expect($('#deck')).not.toBeVisible()
    it "shows only trump if 1 card in deck", ->
      jasmine.getFixtures().load('game.html')
      @game.deck = 0
      GameHelper.loadData($('#gamefield'), @game)
      expect($('#trump')).not.toBeVisible()
      expect($('#deck')).not.toBeVisible()
    it "shows table cards", ->
      expect($("#table .cardsStack").length).toBe(2)
      firstStack = $("#table .cardsStack:first")
      expect(firstStack).toContain(".attackCard.card.cards-spades8")
      expect(firstStack).toContain(".defenseCard.card.cards-spades9")
      secondStack = $("#table .cardsStack:gt(0)")
      expect(secondStack).toContain(".attackCard.card.cards-hearts9")
      expect(secondStack).not.toContain(".defenseCard")

describe "card to image converter", ->
  verifyClass = (suit, card, image) ->
    expect(GameHelper.class_name({'card': card, 'suit': suit})).toBe(image)
  it "converts suit", ->
    verifyClass('Heart', 'Queen', 'cards-heartsq')
    verifyClass('Spade', 'King', 'cards-spadesk')
    verifyClass('Diamond', 'Jack', 'cards-diamondsj')
    verifyClass('Club', '10', 'cards-clubs10')

