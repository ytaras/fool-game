describe 'GameHelper', ->
  it "creates card div from card spec", ->
    card = {"card": "6", "suit": "Hearts"}
    div = $(GameHelper.createCardDiv card)
    expect(div).toHaveClass 'card'
    expect(div).toHaveData('card', '6')
    expect(div).toHaveData('suit', 'Hearts')

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

  describe "card to image converter", ->
    verifyPath = (suit, card, image) ->
      #      TODO Convert to data-url or sprites
      expect(GameHelper.image_url({'card': card, 'suit': suit})).toBe(image)
    it "converts suit", ->
      verifyPath('Hearts', '6', 'hearts-6-75.png')
      verifyPath('Spades', 'King', 'spades-k-75.png')
      verifyPath('Diamonds', 'Jack', 'diamonds-j-75.png')
      verifyPath('Clubs', '10', 'clubs-10-75.png')

