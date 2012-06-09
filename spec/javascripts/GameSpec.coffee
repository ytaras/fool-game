describe 'GameHelper', ->
  it "creates card div from card spec", ->
    card = {"card": "6", "suit": "Hearts"}
    div = $(GameHelper.createCardDiv card)
    expect(div).toHaveClass 'card'
    expect(div).toHaveData('card', '6')
    expect(div).toHaveData('suit', 'Hearts')
    expect(div).toContain('span.card')
    expect(div).toContain('span.suit')

  describe "load game", ->
    beforeEach ->
      jasmine.getFixtures().set('<div id="fixture"><div id="trump"></div></div>')
      @game = {
      trumpCard:
        {
        suit: 'Hearts',
        card: 'Ace'
        }
      }
      GameHelper.loadData($('#fixture'), @game)
    it "creates trump as a card", ->
      expect($('#trump')).toContain('div.card')
