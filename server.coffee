
###
Module dependencies
###

express = require 'express'
routes = require './routes'
user = require './routes/user'
http = require 'http'
path = require 'path'
assets = require 'connect-assets'

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use require('stylus').middleware(__dirname + '/public')
  app.use express.static(path.join(__dirname, 'public'))
  app.use assets()

# development only
app.configure 'development', ->
  app.use express.errorHandler()
  app.set 'enableTest', true
  app.set 'view options', { pretty: true }
  app.locals.pretty = true

app.configure ->
  app.get '/', routes.index
  app.get '/users', user.list

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{ app.get 'port' }"


# end
