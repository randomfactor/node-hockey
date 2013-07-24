# GameState represents a node-hockey game that is about to begin, in progress, or completed
#
# var gmst = require('./lib/game-state')
# var gs = new gmst.GameState()

uuid = require '../lib/math-uuid'

class Vector
  constructor: (x = 0, y = 0) ->
    if typeof x is "object"
      [@x, @y] = [ +x.x, +x.y ]
    else
      [@x, @y] = [ +x, +y ]

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
      [@x, @y] = [+x.x, +x.y]
    else
      [@x, @y] = [+x, +y]
    this

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
      @handle_collisions()

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
    if p.player_status is 'active'
      if @is_out_of_bounds p.position, PLAYER_RADIUS, RINK_BBOX
        # console.dir p
        p.player_status = 'penalty'
        p.position = new Vector 0, -600 # out of sight
        p.velocity = new Vector ZERO_V
        p.acceleration = new Vector ZERO_V
        p.active_ts = new Date()
        return p
      delta_t = (t1 - t0) / 30.0
      p.acceleration.regulate_acceleration p.velocity
      p.position.set Vector.compute_position p.position, p.velocity, p.acceleration, delta_t
      p.velocity.set Vector.compute_velocity p.velocity, p.acceleration, delta_t
      p.velocity.regulate_velocity()
      @check_and_maybe_bounce p.position, p.velocity, p.acceleration, PLAYER_RADIUS, RINK_BBOX
    p

  check_and_maybe_bounce: (pos, vel, accel, r, bbox) ->
    if pos.x < bbox.x0 + r
      accel.x = 0 if accel.x < 0
      vel.x = - vel.x
      pos.x =  2 * (bbox.x0 + r) - pos.x
    else if pos.x > bbox.x1 - r
      accel.x = 0 if accel.x > 0
      vel.x = - vel.x
      pos.x = 2 * (bbox.x1 - r) - pos.x
    if pos.y < bbox.y0 + r
      accel.y = 0 if accel.y < 0
      vel.y = - vel.y
      pos.y = 2 * (bbox.y0 + r) - pos.y
    else if pos.y > bbox.y1 - r
      accel.y = 0 if accel.y > 0
      vel.y = - vel.y
      pos.y = 2 * (bbox.y1 - r) - pos.y

  update_puck_position: (t0, t1) ->
    delta_t = (t1 - t0) / 30.0
    # TODO:
    @puck.position.set Vector.compute_position @puck.position, @puck.velocity, ZERO_V, delta_t
    @check_and_maybe_bounce @puck.position, @puck.velocity, ZERO_V, PUCK_RADIUS, RINK_BBOX
    @puck

  handle_collisions: ->
    ncp = @find_nearest_colliding_player()
    @collide_with_puck ncp if ncp?

  find_nearest_colliding_player: ->
    overlap_distance = PUCK_RADIUS + PLAYER_RADIUS
    colliders = []
    epsilon = 0.0005 # ignore player exactly on top of puck
    for p in @home_team_players.concat @visiting_team_players
      delta = new Vector @puck.position.x - p.position.x, @puck.position.y - p.position.y
      dist = delta.magnitude()
      if delta.magnitude() < overlap_distance and p.velocity.dot_product(delta) > @puck.velocity.dot_product(delta)
        unless p.is_colliding? or dist < epsilon
          colliders.push [dist, p]
      else
        delete p.is_colliding if p.is_colliding?
    return null if colliders.length is 0
    colliders.sort ((a,b) -> a[0] < b[0])
    colliders[0][1].is_colliding = 1 # mark this player
    colliders[0][1]

  collide_with_puck: (p) ->
    normal = new Vector @puck.position.x - p.position.x, @puck.position.y - p.position.y
    normal = normal.scale 1.0 / normal.magnitude()
    tangent = new Vector -normal.y, normal.x
    ptan = tangent.scale p.velocity.dot_product tangent
    ktan = tangent.scale @puck.velocity.dot_product tangent
    pbefore = p.velocity.dot_product normal
    kbefore = @puck.velocity.dot_product normal
    pafter = @conservation_of_momentum pbefore, PLAYER_MASS, kbefore, PUCK_MASS
    kafter = @conservation_of_momentum kbefore, PUCK_MASS, pbefore, PLAYER_MASS
    p.velocity.set normal.scale(pafter).add ptan
    p.velocity.regulate_velocity()
    @puck.velocity.set normal.scale(kafter).add ktan

  conservation_of_momentum: (v1, m1, v2, m2) ->
    (v1 * (m1 - m2) + 2 * m2 * v2) / (m1 + m2)

  is_out_of_bounds: (pos, r, bbox) ->
    pos.x < bbox.x0 + r or pos.x > bbox.x1 - r or pos.y < bbox.y0 + r or pos.y > bbox.y1 - r

  tick_from_date: (d) ->
    Math.round(d.getTime() * 30 / 1000)

  set_acceleration: (pname, acc_x, acc_y) ->
    #console.log "setting #{pname} acceleration to #{acc_x}, #{acc_y}"
    acc = new Vector acc_x, acc_y
    magnitude = acc.magnitude()
    acc = acc.scale(MAX_ACCELERATION / magnitude) if magnitude > MAX_ACCELERATION
    p.acceleration = acc for p in @home_team_players.concat @visiting_team_players when p.name is pname
    acc

  @find_by_id: (id) ->
    rslt = (gm for gm in @active_games when gm._id is id)
    return rslt[0] if rslt?.length >= 1
    if id is '23'
      rslt = new GameState()
      rslt._id = '23'
      p1 = rslt.add_player "P1", true
      p1.velocity.set 233, -56
      p2 = rslt.add_player "P2", false
      p2.acceleration.set -70, 20
      p3 = rslt.add_player "P5", true
      p3.velocity.set 400, 0
      p3.acceleration.set 0, -80
      rslt.puck.velocity.set -100, 100
      @active_games.push rslt
      return rslt
    undefined

ZERO_V = new Vector()
MAX_VELOCITY = 400 # units per second
MAX_ACCELERATION = 160 # units per second per second
PLAYER_RADIUS = 70
PLAYER_MASS = 100
PUCK_RADIUS = 35
PUCK_MASS = 60
BOUND_WID = 5
RINK_BBOX = {
  x0: -1000 + BOUND_WID,
  y0: -1000 * 374 / 780 + BOUND_WID,
  x1: 1000 - BOUND_WID,
  y1: 1000 * 374 / 780
}


exports.GameState = GameState
exports.Vector = Vector

