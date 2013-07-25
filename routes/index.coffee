
###
 * GET home page.
###

gmst = require '../lib/game-state'

exports.index = (req, res) ->
  req.session['playerName'] = 'anonymous' if not req.session['playerName']?
  res.render 'index', { title: 'Node-Hockey' }

exports.test = (req, res) ->
  res.render 'test/test'

exports.ping = (req, res) ->
  res.json
    ping: 'pong'
    server_time: Date.now()

exports.gamestate = (req, res) ->
  # console.dir req.params
  gs = gmst.GameState.find_by_id(req.params.id)
  if gs?
    gs.update()
    res.json(gs)
  else
    res.status(404).send('Not found.')

exports.set_acceleration = (req, res) ->
  gs = gmst.GameState.find_by_id(req.params.id)
  if gs?
    gs.set_acceleration(req.session.player_name, req.body.x, req.body.y)
    res.json('OK')
  else
    res.status(404).send('Not found.')

exports.add_player = (req, res) ->
  gs = gmst.GameState.find_by_id(req.params.id)
  if gs?
    p = gs.add_player()
    req.session.player_name = p.name
    req.session.gamestate_id = gs._id
    res.json { gamestate_id: gs._id, player_name: p.name }
  else
    res.status(404).send('Not found.')