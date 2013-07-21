game = require '../lib/game-state'

xdescribe "A suite", ->
  it "contains spec with an expectation", (done) ->
    gs = new game.GameState()
    expect(gs.home_team.length).toBe 2
    done()

  it "The 'toBeCloseTo' matcher is for precision math comparison", ->
    pi = 3.1415926
    e = 2.78

    expect(pi).not.toBeCloseTo(e, 2)
    expect(pi).toBeCloseTo(e, 0)
    expect(1.02).toBeCloseTo(1.06, 1)