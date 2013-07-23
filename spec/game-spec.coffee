game = require '../lib/game-state'
Vector = game.Vector
GameState = game.GameState
util = require 'util'

describe "Vector constructor", ->
  it "defaults to the origin", ->
    v = new Vector()
    expect(v.x).toBe(0)
    expect(v.y).toBe(0)
  it "initializes from two numbers", ->
    v = new Vector 1, 2
    expect(v.x).toBe 1
    expect(v.y).toBe 2
  it "initializes from an object with x and y", ->
    v = new Vector { x: 3, y: 4 }
    expect(v.x).toBe 3
    expect(v.y).toBe 4

describe "Vector operations", ->
  it "computes a new position", ->
    p0 = new Vector(0, 16)
    v = new Vector(16, 0)
    a = new Vector(0, -32)
    p1 = Vector.compute_position p0, v, a, 1.0
    expect(p1.x).toBe 16
    expect(p1.y).toBeCloseTo 0, 2
  it "computes a new velocity", ->
    v0 = new Vector(32, 0)
    a = new Vector(0, -32)
    v1 = Vector.compute_velocity v0, a, 1.0
    expect(v1).toEqual new Vector 32, -32
  it "throttles excessive velocity", ->
    v = new Vector 400 * Math.sqrt(2) / 2, -400 * Math.sqrt(2) / 2
    a = new Vector 80 * Math.sqrt(2) / 2, -80 * Math.sqrt(2) / 2
    v1 = Vector.compute_velocity v, a, 1.0 / 30.0
    v1.regulate_velocity()
    expect(v1).toEqual v
  it "throttles excessive acceleration", ->
    v = new Vector 320, 236
    a = new Vector 48, 64
    a.regulate_acceleration v
    expect(a.magnitude()).toBeLessThan 40
    v1 = Vector.compute_velocity v, a, 0.5
    expect(v1.magnitude()).toBeLessThan 410
    v1.regulate_velocity()
    expect(v1.magnitude()).not.toBeGreaterThan 400


describe "Calculate player next position", ->
  it "computes the next player position (constant velocity)", (done) ->
    gs = new GameState()
    p = reinflate_player jcopy players[0]
    for tick in [41231410239..41231410268]
      gs.update_player_position p, tick, tick + 1
    expect(p.position.x).toBeCloseTo players[0].position.x + 400, 5
    done()
  it "computes the next player position (constant acceleration)", (done) ->
    gs = new GameState()
    p = reinflate_player jcopy players[1]
    for tick in [41231410239..41231410268]
      gs.update_player_position p, tick, tick + 1
    expect(p.position.x).toBeCloseTo players[1].position.x + 40, 5
    done()
  it "computes the next player position (max velocity)", (done) ->
    gs = new GameState()
    p = reinflate_player jcopy players[2]
    for tick in [41231410239..41231410268]
      gs.update_player_position p, tick, tick + 1
    expect(p.acceleration.x).toBeCloseTo 0, 2
    done()
  it "puts player in penalty state when boundary exceeded", (done) ->
    gs = new GameState()
    p = reinflate_player jcopy players[0]
    tick = 41231410239
    delta_ticks = 30 * ( 1470 + 1860 + 20) / 400 # enough ticks to cross rink twice
    gs.update_player_position p, tick, tick + delta_ticks
    expect(p.position.x).toBeLessThan -400 / 30
    expect(p.player_status).toBe 'active'
    gs.update_player_position p, tick + delta_ticks, tick + delta_ticks + 1
    #console.dir p
    expect(p.position.y).toBe -600
    expect(p.player_status).toBe 'penalty'
    done()

describe "Rink edge", ->
  it "bounces player off left wall", (done) ->
    gs = new GameState()
    p = reinflate_player jcopy players[3]
    tick = 41231410239
    delta_ticks = Math.ceil(30 * 100 / 200) # enough ticks to travel 100 units
    #console.log "traveling for #{delta_ticks} ticks"
    #console.dir p.position
    gs.update_player_position p, tick, tick + delta_ticks
    #console.dir p.position
    expect(p.position.x).toBe -875
    expect(p.position.y).toBe -375
    expect(p.player_status).toBe 'active'
    done()
  it "bounces player off right and bottom walls", (done) ->
    gs = new GameState()
    p = reinflate_player jcopy players[4]
    tick = 41231410239
    delta_ticks = Math.ceil(30 * 210 / 200) # enough ticks to travel 210 units
    #console.log "traveling for #{delta_ticks} ticks"
    #console.dir p.position
    gs.update_player_position p, tick, tick + delta_ticks
    #console.dir p.position
    expect(p.position.x).toBeCloseTo 782, 0
    expect(p.position.y).toBeCloseTo 341, 0
    expect(p.player_status).toBe 'active'
    done()


describe "Game state", ->
  it "finds game 23", ->
    gs23 = GameState.find_by_id('23')
    expect(gs23).not.toBeUndefined
    expect(GameState.active_games.length).toBe(1)
    gs = GameState.find_by_id('23')
    expect(gs).toBe(gs23)
    expect(GameState.active_games.length).toBe(1)
  it "doesn't find game 24", ->
    gs = GameState.find_by_id('24')
    expect(gs).toBeUndefined()
  it "updates itself for the next tick", ->
    gs = new GameState()
    playa = gs.add_player 'P1', true
    xpos = playa.position.x
    gs.home_team_players[0].velocity = new Vector 100, 0
    gs.update gs.current_tick + 30
    #console.log util.inspect gs, { depth: 8 }
    expect(playa.position.x).toBe(xpos + 100)
  it "set players acceleration", ->
    gs = new GameState()
    playa = gs.add_player 'P1', true
    gs.set_acceleration 'P1', -120, 160
    expect(playa.acceleration.x).toBe -96
    expect(playa.acceleration.y).toBe 128


players = [
  { name: 'P3', player_status: 'active', position: new Vector(-500, 0), velocity: new Vector(400, 0), acceleration: new Vector(0, 0), active_ts: 1374287939999  }
  { name: 'P6', player_status: 'active', position: new Vector(-920, 0), velocity: new Vector(0, 0), acceleration: new Vector(80, 0), active_ts: 1374287939999  }
  { name: 'P7', player_status: 'active', position: new Vector(-920, 0), velocity: new Vector(392, 0), acceleration: new Vector(72, 30), active_ts: 1374287939999  }
  { name: 'P0', player_status: 'active', position: new Vector(-875, -400), velocity: new Vector(-200, 50), acceleration: new Vector(0, 0), active_ts: 1374287939999  }
  { name: 'P1', player_status: 'active', position: new Vector(855, 264.5), velocity: new Vector(200, 200), acceleration: new Vector(0, 0), active_ts: 1374287939999  }
]

jcopy = (obj) ->
  JSON.parse JSON.stringify obj

reinflate_player = (p) ->
  p.position = new Vector(p.position) if typeof p.position is 'object'
  p.velocity = new Vector(p.velocity) if typeof p.velocity is 'object'
  p.acceleration = new Vector(p.acceleration) if typeof p.acceleration is 'object'
  p