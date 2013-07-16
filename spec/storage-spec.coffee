stor = require '../lib/storage'
game = require '../lib/game-state'

describe "Savespec", ->
  it "saves a simple document", (done) ->
    dbc = new stor.Storage()
    gs = new game.GameState()
    p = dbc.save gs
    p.then(
      (body) ->
        expect(body?).toBeTrue
        expect(body._id).toEqual(gs._id)
        done()
      (err) ->
        console.log "error: "
        console.dir err
        done()
    )