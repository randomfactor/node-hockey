App = Ember.Application.create { rootElement: '#content', LOG_TRANSITIONS: true }

App.Router.map () ->
  this.route 'intro'
  this.route 'play'

App.IndexRoute = Ember.Route.extend {
  redirect: ->
    console.log 'transition to intro'
    @transitionTo('intro')
}

App.Store = DS.Store.extend {
  revision: 13,
  adapter: DS.FixtureAdapter.create()
}

App.Game = DS.Model.extend {
  rinkId: DS.attr('string')
  gamestateId: DS.attr('string')
  homeTeamName: DS.attr('string')
  visitingTeamName: DS.attr('string')
  homeTeamScore: DS.attr('number')
  visitingTeamScore: DS.attr('number')
}

App.Game.FIXTURES = [
  { id: 1, rinkId: '1', gamestateId: '23', homeTeamName: 'Blackhawks', visitingTeamName: 'Bruins', homeTeamScore: 1, visitingTeamScore: 3 }
  { id: 2, rinkId: '2', gamestateId: '23', homeTeamName: 'Nerds', visitingTeamName: 'Jocks', homeTeamScore: 123, visitingTeamScore: 0 }
]


App.PlayRoute = Ember.Route.extend  {
  model: () -> App.Game.find(1)

  setupController: (controller, model) ->
    controller.set 'model', model
    controller.enroll() # add this player
}

App.AccelerationView = Ember.View.extend {
  click: (evt) ->
    this.get('controller').send('onSetAcceleration', evt.offsetX, evt.offsetY)
}

App.PlayController = Ember.ObjectController.extend {
  # lagValues contains up to 10 net lag measurements in milliseconds
  # if showNetLag is false, lagValues <-- [] and N/A is displayed
  lagValues: []
  showNetLag: false
  init: ->
    @_super()

  onSetAcceleration: (x, y) ->
    rink = @get('rink')
    rink.send_acceleration_req x, y if rink?

  onShowNetLagChanged: (() ->
    @measureNetLag() if @showNetLag
  ).observes('showNetLag')

  # compute average of up to 10 net lag measurements
  netLag: ->
    @set 'lagValues', [] if not @get 'showNetLag'
    vals = @get('lagValues')
    return 'N/A' if vals.length < 1
    (vals.reduce((acc, t) -> acc + t) / vals.length).toFixed 1

  # measure net lag every 3 seconds
  measureNetLag: ->
    @lagStart = new Date().getTime()
    $.get '/ping', (data) =>
      msArray = @get 'lagValues'
      msArray.shift() if msArray.length >= 10
      msArray.push new Date().getTime() - @lagStart
      $('#net-lag').text @netLag()
    setTimeout (() => @measureNetLag()), 3000 if @showNetLag

  rink: null
  is_watching: false

  cannotStart: ( ->
    @get('is_watching')
  ).property('is_watching')

  canStart: ( ->
    not @get('is_watching')
  ).property('is_watching')

  enroll: ->
    console.dir @get('gamestateId')
    gs_id = @get('gamestateId')
    $.post "/gs/#{gs_id}/add", { }, (data, stat, xhr) =>
      pname = data.player_name
      @set 'rink', new Rink pname, gs_id
      @startWatching()

  startWatching: ->
    @get('rink').start_watching()
    @set 'is_watching', true

  stopWatching: ->
    @set 'is_watching', false
    @get('rink').stop_watching()
}

window.App = App                         # for debugging
