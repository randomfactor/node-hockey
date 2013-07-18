couchapp = require('couchapp')
path = require('path');

ddoc = {
  _id: '_design/app'
  views:
    gamestateByStart:
      map: (doc) ->
        emit doc.start_ts, doc._id if doc.type == "GameState"
  lists: {}
  shows: {}
}

module.exports = ddoc

couchapp.loadAttachments ddoc, path.join(__dirname, 'attachments')
