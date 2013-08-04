

couchdb = require('then-couchdb')
require '../lib/math-uuid'

class RinkState
  @db = couchdb.createClient('http://localhost:5984/node-hockey')
  constructor: (config) ->
    @_id = Math.uuid()
    @type = this.constructor.name
    @create_ts = new Date()
    @home_team_name = "Home"
    @visiting_team_name = "Visitor"
    @max_players_per_team = 3
    @final_score = 4

    if typeof config is 'object'
      @[key] = val for key, val of config


  save: ->
    @constructor.db.save(this)

  @find_by_id: (key) ->
    @db.get(key)

  @find_all: (query) ->
    q = { descending: true, limit: 20, include_docs: true }
    if typeof query is 'object'
      q[key] = val for key, val of query
    @db.view 'app/rinkstateByCreate', q

exports.RinkState = RinkState

