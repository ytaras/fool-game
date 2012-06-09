describe 'Game', ->
  it "creates card div from card spec", ->
    card = {"card": "6", "suit": "Hearts"}
    div = GameHelper.createCardDiv card
    expect(div).toHaveClass 'card'
    expect(div).toHaveAttr('data-card', '6')
    expect(div).toHaveAttr('data-suit', 'Hearts')
    expect(div).toContain('span.card')
    expect(div).toContain('span.suit')
