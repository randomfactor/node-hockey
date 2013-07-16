game = require '../lib/game-state'

describe "A suite", ->
  it "contains spec with an expectation", (done) ->
    gs = new game.GameState()
    expect(gs.home_team.length).toBe 2
    done()
