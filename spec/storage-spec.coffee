stor = require '../lib/storage'
game = require '../lib/game-state'

xdescribe "Savespec", ->
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
        expect(err).toBeUndefined()
        done()
    )

xdescribe "Indexspec", ->
  it "gets the 20 most recent documents", (done) ->
    dbc = new stor.Storage()
    p = dbc.get_active_gamestates()
    p.then(
      (body_arr) ->
        #console.dir body_arr
        expect(body_arr?.total_rows).not.toBeUndefined()
        expect(body_arr?.total_rows).not.toBeNull()
        expect(body_arr.rows.length).toBeGreaterThan(0)
        done()
      (err) ->
        console.log "error: "
        console.dir err
        expect(err).toBeUndefined()
        done()
    )