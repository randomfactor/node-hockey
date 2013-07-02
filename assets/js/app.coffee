App = Ember.Application.create { rootElement: '#content' }

App.Router.map () ->
  this.route 'index'
  this.route 'play'

App.IndexRoute = Ember.Route.extend {
  model: () -> ['red', 'yellow', 'blue']
}
