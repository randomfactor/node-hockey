game = require '../lib/game-state'
Vector = game.Vector
GameState = game.GameState

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
  xit "computes a new position", ->
    p0 = new Vector(0, 16)
    v = new Vector(16, 0)
    a = new Vector(0, -32)
    p1 = Vector.compute_position p0, v, a, 1.0
    expect(p1.x).toBe 16
    expect(p1.y).toBeCloseTo 0, 2
  xit "computes a new velocity", ->
    v0 = new Vector(32, 0)
    a = new Vector(0, -32)
    v1 = Vector.compute_velocity v0, a, 1.0
    expect(v1).toEqual new Vector 32, -32
  xit "throttles excessive velocity", ->
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


describe "Gamespec", ->
  it "computes the next player position", (done) ->
    p = jcopy players[0]
    expect(p.position.x).toEqual(players[0].position.x)
    done()

players = [
  { name: 'P3', player_status: 'active', position: new Vector(-500, 0), velocity: new Vector(400, 0), acceleration: new Vector(0, 0), active_ts: 1374287939999  }
]

jcopy = (obj) ->
  JSON.parse JSON.stringify obj