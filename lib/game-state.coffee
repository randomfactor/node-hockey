# GameState represents a node-hockey game that is about to begin, in progress, or completed
#
# var gmst = require('./lib/game-state')
# var gs = new gmst.GameState()

uuid = require '../lib/math-uuid'

class Vector
  constructor: (@x=0, @y=0) ->
    if typeof @x is "object"
      [@x, @y] = [@x.x, @x.y]

  @compute_position: (p0, v0, a, t) ->
    x = p0.x + v0.x * t + 0.5 * a.x * t * t
    y = p0.y + v0.y * t + 0.5 * a.y * t * t
    new Vector(x, y)

  @compute_velocity: (v0, a, t) ->
    x = v0.x + a.x * t
    y = v0.y + a.y * t
    new Vector(x, y)

  regulate_velocity: ->
    sum_squares = @x * @x + @y * @y
    if sum_squares > MAX_VELOCITY * MAX_VELOCITY
      factor = Math.sqrt(MAX_VELOCITY * MAX_VELOCITY / sum_squares)
      @x = @x * factor
      @y = @y * factor
    this

  regulate_acceleration: (v0) ->
    amag_projected = @dot_product(v0) / v0.magnitude()
    max_accel_at_velocity = 2 * (MAX_VELOCITY - v0.magnitude())
    if amag_projected > max_accel_at_velocity
      # reduce projected accel, but allow perpendicular accel
      aproj = v0.scale(amag_projected / v0.magnitude())
      aperp = @add aproj.scale(-1.0)      # a_perpendicular = a - a_projected

      aprojreduced = aproj.scale(max_accel_at_velocity / aproj.magnitude())
      @set aprojreduced.add aperp
    this

  magnitude: ->
    Math.sqrt(@x * @x + @y * @y)

  dot_product: (vec) ->
    @x * vec.x + @y * vec.y

  scale: (factor) ->
    new Vector @x * factor, @y * factor

  add: (vec) ->
    new Vector @x + vec.x, @y + vec.y

  set: (x, y) ->
    if typeof x is "object"
      [@x, @y] = [x.x, x.y]
    else
      [@x, @y] = [x, y]

class GameState
  constructor: ->
    @_id = Math.uuid()
    @type = this.constructor.name
    @start_ts = new Date()
    @current_tick = @tick_from_date @start_ts
    @home_team_players = [ ]
    @visiting_team_players = [ ]
    @puck = {
      puck_status: 'active'
      position: new Vector 0, 0
      velocity: new Vector 0, 0
    }
    @home_team_score = 0
    @visiting_team_score = 0

  @active_games = []

  update: (next_tick) ->
    next_tick = @tick_from_date new Date() unless next_tick?
    if next_tick > @current_tick
      @update_player_position(p, @current_tick, next_tick) for p in @home_team_players
      @update_player_position(p, @current_tick, next_tick) for p in @visiting_team_players
      @update_puck_position @current_tick, next_tick
      @current_tick = next_tick

  add_player: (name, is_homey) ->
    new_player = {
      name: name
      player_status: 'active' # TODO: change to 'rezzing'
      position: new Vector (if is_homey then -800 else 800), 50
      velocity: new Vector()
      acceleration: new Vector()
      active_ts: new Date()
    }
    if is_homey
      @home_team_players.push new_player
    else
      @visiting_team_players.push new_player
    new_player

  update_player_position: (p, t0, t1) ->
    delta_t = (t1 - t0) / 30.0
    p.acceleration.regulate_acceleration p.velocity
    p.position.set Vector.compute_position p.position, p.velocity, p.acceleration, delta_t
    p.velocity.set Vector.compute_velocity p.velocity, p.acceleration, delta_t
    p.velocity.regulate_velocity
    p

  update_puck_position: (t0, t1) ->
    delta_t = (t1 - t0) / 30.0
    # TODO:
    @puck.position.set Vector.compute_position @puck.position, @puck.velocity, ZERO_ACCELERATION, delta_t
    @puck

  tick_from_date: (d) ->
    Math.round(d.getTime() * 30 / 1000)

  @find_by_id: (id) ->
    rslt = (gm for gm in @active_games when gm._id is id)
    return rslt[0] if rslt?.length >= 1
    if id is '23'
      rslt = new GameState()
      rslt._id = '23'
      rslt.add_player "P1", true
      @active_games.push rslt
      return rslt
    undefined

ZERO_ACCELERATION = new Vector()
MAX_VELOCITY = 400 # units per second
MAX_ACCELERATION = 80 # units per second per second


exports.GameState = GameState
exports.Vector = Vector

