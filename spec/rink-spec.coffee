RinkState = require('../lib/rink-state').RinkState

describe "RinkState constructor", ->
  it "merges config and saves to db", (done) ->
    r = new RinkState { home_team_name: 'Blackhawks', visiting_team_name: 'Bruins', max_players_per_team: 4 }
    expect(r.max_players_per_team).toBe 4
    r.save().then((data) ->
      expect(data._rev).not.toBeUndefined()
      RinkState.find_by_id(data._id)
    ).then((doc) ->
      expect(doc.max_players_per_team).toBe 4
      done()
    (err) ->
      console.dir err
      done()
    )
  it "get up to 20 latest rinks from db", (done) ->
    RinkState.find_all().then((data) ->
      expect(data.total_rows).not.toBeGreaterThan 20
      expect(data.total_rows).toBeGreaterThan 0
      done()
    (err) ->
      console.dir err
      done()
    )

