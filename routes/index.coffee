
###
 * GET home page.
###

exports.index = (req, res) ->
  res.render 'index', { title: 'Node-Hockey' }

exports.test = (req, res) ->
    res.render 'test/test'
