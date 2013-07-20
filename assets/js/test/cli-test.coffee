
describe 'JavaScript addtion operator', ->
  it 'adds two numbers together', ->
    expect(1 + 2).toEqual(3)

describe 'Rink rendering tests', ->
  it 'renders one player and the puck', ->
    gs = test_state[0]
    r = new Rink 'P1'
    r.render(gs)
    expect(2 + 3).toEqual(5)

test_state = [
  {
    current_tick: 1374287941943
    home_team_players: [
      { name: 'P1', player_status: 'active', position: new Pt(-0.5, -0.1), velocity: new Pt(0, 0), acceleration: new Pt(0, 0), active_ts: 1374287939999  }
    ]
    visiting_team_players: [
      { name: 'P3', player_status: 'active', position: new Pt(0.5, 0.1), velocity: new Pt(0, 0), acceleration: new Pt(0, 0), active_ts: 1374287939999  }
      { name: 'P2', player_status: 'active', position: new Pt(-0.46, -0.12), velocity: new Pt(0, 0), acceleration: new Pt(0, 0), active_ts: 1374287939999  }
    ]
    puck: { puck_status: 'active', position: new Pt(0, 0), velocity: new Pt(0, 0) }
  }
]
###
GameState
  id
  rink_state_id
  start_ts
  current_tick
  home_team_players
    [[num, player_status, position, velocity, acceleration, active_ts], ...]
  visiting_team_players
    [[num, player_status, position, velocity, acceleration, active_ts], ...]
  puck
    [puck_status, position, velocity, acceleration]
  home_team_score
  visiting_team_score
###
