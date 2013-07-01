App = Ember.Application.create({
    rootElement: '#content'
});

App.Router.map(function() {
    this.route('index');
    this.route('play');
});

App.IndexRoute = Ember.Route.extend({
  model: function() {
    return ['red', 'yellow', 'blue'];
  }
});
