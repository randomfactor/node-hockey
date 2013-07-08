
###
 * GET home page.
###

exports.index = (req, res) ->
  req.session['playerName'] = 'anonymous' if not req.session['playerName']?
  res.render 'index', { title: 'Node-Hockey' }

exports.test = (req, res) ->
  res.render 'test/test'

exports.ping = (req, res) ->
  res.json
    ping: 'pong'
    server_time: Date.now()
