# GameState represents a node-hockey game that is about to begin, in progress, or completed

class GameState
  constructor: ->
    @home_team = [ 'P1', 'P4' ]
    @visiting_team = [ 'P2', 'P3' ]

exports.GameState = GameState
