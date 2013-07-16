# GameState represents a node-hockey game that is about to begin, in progress, or completed
#
# var gmst = require('./lib/game-state')
# var gs = new gmst.GameState()

uuid = require '../lib/math-uuid'

class GameState
  constructor: ->
    @_id = Math.uuid()
    @type = this.constructor.name
    @home_team = [ 'P1', 'P4' ]
    @visiting_team = [ 'P2', 'P3' ]

exports.GameState = GameState
