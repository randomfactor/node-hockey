App = Ember.Application.create { rootElement: '#content', LOG_TRANSITIONS: true }

App.Router.map () ->
  this.route 'index'
  this.route 'play'

App.IndexRoute = Ember.Route.extend {
  redirect: ->
    @transitionTo('index')
  model: () -> ['red', 'yellow', 'blue']
}

App.Store = DS.Store.extend {
  revision: 13,
  adapter: DS.FixtureAdapter.create()
}

App.Game = DS.Model.extend {
  homeTeamName: DS.attr('string')
  visitingTeamName: DS.attr('string')
  homeTeamScore: DS.attr('number')
  visitingTeamScore: DS.attr('number')
}

App.Game.FIXTURES = [
  { id: 1, homeTeamName: 'Blackhawks', visitingTeamName: 'Bruins', homeTeamScore: 1, visitingTeamScore: 3 }
  { id: 2, homeTeamName: 'Nerds', visitingTeamName: 'Jocks', homeTeamScore: 123, visitingTeamScore: 0 }
]


App.PlayRoute = Ember.Route.extend  {
  model: () -> App.Game.find(2)
}

App.PlayController = Ember.ObjectController.extend {
  # lagValues contains up to 10 net lag measurements in milliseconds
  # if showNetLag is false, lagValues <-- [] and N/A is displayed
  lagValues: []
  showNetLag: false
  init: ->
    @_super()

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
}

window.App = App                         # for debugging
