couchapp = require('couchapp')
path = require('path');

ddoc = {
  _id: '_design/app'
  views:
    gamestateByStart:
      map: (doc) ->
        emit doc.start_ts, doc._id if doc.type is "GameState"
    rinkstateByCreate:
      map: (doc) ->
        emit doc.create_ts, true if doc.type is "RinkState"
  lists: {}
  shows: {}
}

module.exports = ddoc

couchapp.loadAttachments ddoc, path.join(__dirname, 'attachments')
