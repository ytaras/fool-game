describe 'GameHelper', ->
  beforeEach ->
    @game =
      trumpCard:
        suit: 'Heart'
        card: 'Ace'
      deck: 2
      cards: [
        {suit: 'Heart', card: '6'}
        {suit: 'Spade', card: '7'}
      ]
      opponent: 3
      myMove: true
      table: [
        [
          {suit: 'Spade', card: '8'},
          {suit: 'Spade', card: '9'}
        ]
        [
          {suit: 'Heart', card: '9'}
        ]
      ]
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
      expect($("#table .cards-stack").length).toBe(2)
      firstStack = $("#table .cards-stack:first")
      expect(firstStack).toContain(".attack-card.card.cards-spades8")
      expect(firstStack).toContain(".defense-card.card.cards-spades9")
      secondStack = $("#table .cards-stack:gt(0)")
      expect(secondStack).toContain(".attack-card.card.cards-hearts9")
      expect(secondStack).not.toContain(".defense-card")
    it "shows opponent cards", ->
      expect($("#opponent_cards .card").length).toBe(3)
    describe 'when game is reloaded', ->
      beforeEach ->
        @game.table = [
          [
            {suit: 'Spade', card: '8'},
            {suit: 'Spade', card: '9'}
          ]
          [
            {suit: 'Heart', card: '9'}
            {suit: 'Heart', card: '10'}
          ]
        ]
        @game.opponent = 4
        @game.deck = 1
        GameHelper.loadData($('#gamefield'), @game)
      it "adds card to a table", ->
        expect($("#table .cards-stack").length).toBe(2)
        secondStack = $("#table .cards-stack:gt(0)")
        expect(secondStack).toContain(".attack-card.card.cards-hearts9")
        expect(secondStack).toContain(".defense-card.card.cards-hearts10")
      it "adds opponent cards to a table", ->
        expect($("#opponent_cards .card").length).toBe(4)
      it "adds opponent cards to a table", ->
        expect($('#deck')).not.toBeVisible


  describe "card to image converter", ->
    verifyClass = (suit, card, image) ->
      expect(GameHelper.class_name({'card': card, 'suit': suit})).toBe(image)
    it "converts suit", ->
      verifyClass('Heart', 'Queen', 'cards-heartsq')
      verifyClass('Spade', 'King', 'cards-spadesk')
      verifyClass('Diamond', 'Jack', 'cards-diamondsj')
      verifyClass('Club', '10', 'cards-clubs10')

  describe "card_click", ->
    beforeEach ->
      spyOn($, "ajax").andCallFake (options) ->
    describe 'on my move', ->
      beforeEach ->
        @game.myMove = true
        jasmine.getFixtures().load('game.html')
        GameHelper.loadData $("#gamefield"), @game
      it "issues an ajax request on put", ->
        GameHelper.card_click @game.cards[0]
        options = $.ajax.mostRecentCall.args[0]
        expect(options["url"]).toBe "/game/move"
        expect(options["type"]).toBe "POST"
        expect(options["data"]).toEqual
          move: "put"
          card: @game.cards[0]
      it "can handle div elements corectly", ->
        GameHelper.card_click $("#hand ." + GameHelper.class_name(@game.cards[0]))[0]
        options = $.ajax.mostRecentCall.args[0]
        expect(options["data"]).toEqual
          move: "put"
          card: @game.cards[0]

    describe 'on his move', ->
      beforeEach ->
        @game.myMove = false
        jasmine.getFixtures().load('game.html')
        GameHelper.loadData $("#gamefield"), @game
      it "issues an ajax request on put", ->
        GameHelper.card_click @game.cards[0]
        options = $.ajax.mostRecentCall.args[0]
        expect(options["url"]).toBe "/game/move"
        expect(options["type"]).toBe "POST"
        expect(options["data"]).toEqual
          move: "beat"
          card: @game.cards[0]


  describe 'changes applier', ->
    beforeEach ->
      @result =
        trumpCard:
          suit: 'Heart'
          card: 'Ace'
        deck: 2
        cards: [
          {suit: 'Heart', card: '6'}
          {suit: 'Spade', card: '7'}
        ]
        opponent: 3
        myMove: true
        table: [
          [
            {suit: 'Spade', card: '8'}
            {suit: 'Spade', card: '9'}
          ]
          [
            {suit: 'Heart', card: '9'}
            {suit: 'Heart', card: '10'}
          ]
          [
            {suit: 'Diamond', card: '9'}
            {suit: 'Diamond', card: '10'}
          ]
          [
            {suit: 'Spade', card: '8'},
          ]
        ]
        changes:
          table:
            added: [
              [ undefined, {suit: 'Heart', card: '10'} ]
              [
                {suit: 'Diamond', card: '9'}
                {suit: 'Diamond', card: '10'}
              ]
              [
                {suit: 'Spade', card: '8'}
              ]
            ]
      jasmine.getFixtures().load('game.html')
      GameHelper.loadData($('#gamefield'), @game)
      GameHelper.applyChanges($('#gamefield'), @result)
    it 'has result', ->
      expect(@result).toBeDefined()
      expect($('#table .cards-stack .card')).toExist()
    it 'beats card on a table', ->
      expect($("#table .cards-stack .defense-card.card.cards-hearts10")).toExist()
    it 'adds attack card on a table', ->
      expect($("#table .cards-stack .attack-card.card.cards-spades8")).toExist()
    it 'adds full stack on a table', ->
      expect($("#table .cards-stack .attack-card.card.cards-diamonds9")).toExist()
      expect($("#table .cards-stack .defense-card.card.cards-diamonds10")).toExist()
