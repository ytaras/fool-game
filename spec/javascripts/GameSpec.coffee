describe 'Game', ->
  describe 'Play', ->
    it "creates card div from card spec", ->
      expect(GameHelper.createCardDiv({"card": "6", "suit": "Health"})).toBeDefined
