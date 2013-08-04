
###
Module dependencies
###

express = require 'express'
routes = require './routes'
user = require './routes/user'
rink = require './routes/rink'
http = require 'http'
path = require 'path'
assets = require 'connect-assets'
sessStore = require('connect-redis')(express)

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  # app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session { secret: "bodyCheckingNodeHockey", store: new sessStore { db: 2 } }
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
  app.get '/test', routes.test

app.configure ->
  app.get '/', routes.index
  app.get '/users', user.list
  app.get '/ping', routes.ping
  app.get '/gs/:id', routes.gamestate
  app.post '/gs/:id', routes.set_acceleration
  app.post '/gs/:id/add', routes.add_player

  app.get '/rinks', rink.index
  app.post '/rinks', rink.create
  app.get '/rinks/:id', rink.find
  app.put '/rinks/:id', rink.modify
  app.delete 'rinks/:id', rink.delete


http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{ app.get 'port' }"


# end
