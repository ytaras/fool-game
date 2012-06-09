describe 'GameHelper', ->
  it "creates card div from card spec", ->
    card = {"card": "6", "suit": "Hearts"}
    div = $(GameHelper.createCardDiv card)
    expect(div).toHaveClass 'card'
    expect(div).toHaveData('card', '6')
    expect(div).toHaveData('suit', 'Hearts')
    expect(div).toContain('span.card_value')
    expect(div).toContain('span.suit')

  describe "load game", ->
    beforeEach ->
      jasmine.getFixtures().load('game.html')
      @game =
        trumpCard:
          suit: 'Hearts'
          card: 'Ace'
        deck: 2
        cards: [
          {suit: 'Hearts', card: '6'}
          {suit: 'Spades', card: '7'}
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