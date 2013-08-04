RinkState = require('../lib/rink-state.coffee').RinkState


#app.get '/rinks', Rink.index
exports.index = (req, res) ->
  RinkState.find_all(req.query).then((data) ->
    res.json(data.rows)
  (err) ->
    console.error err
    res.status(404).send('Not found.')
  )

#app.post '/rinks', Rink.create
exports.create = (req, res) ->
  res.send 'create'

#app.get '/rinks/:id', Rink.find
exports.find = (req, res) ->
  id = req.params.id
  RinkState.find_by_id(id, req.query).then((data) ->
    res.json(data)
  (err) ->
    console.error err
    res.status(404).send('Not found.')
  )

#app.put '/rinks/:id', Rink.modify
exports.modify = (req, res) ->
  res.send 'modify'

#app.delete 'rinks/:id', Rink.delete
exports.delete = (req, res) ->
  res.send 'delete'

