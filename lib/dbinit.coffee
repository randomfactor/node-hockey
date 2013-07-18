# As of 18 July 2013, this still isn't working. It was an
# attempte to eliminate the need for couchapp as a mechanism
# to load the design document. I may return to this because
# I hate the way that couchapp drags every gorram simple
# utility into my project to do things that I don't even
# want to do (like include the attachments folder).

dbserver = 'http://randall:realsoon@localhost:5984'
dbname = 'node-hockey'

couchdb = require 'then-couchdb'
uuid = require '/home/randall/Projects/node-hockey/lib/math-uuid.js'

ddoc =
  _id: '_design/hockey'
  rewrites: {}
  views: {}
    #gamestateByStart:
    #  map: (doc) ->
    #    if doc.type is 'GameState'
    #      emit doc.start_ts, doc._id
    #  reduce: '_count'

  shows: {}
  lists: {}
  validate_doc_update: (newDoc, oldDoc, userCtx) ->
    if newDoc._deleted == true && userCtx.roles.indexOf('_admin') == -1
      throw "Only admin can delete documents on this database."

# TODO: convert functions in ddoc to strings
console.dir ddoc
console.log JSON.stringify(ddoc)
db = couchdb.createClient dbserver + '/' + dbname
p1 = db.update('_design/hockey', ddoc)
p1.then(
  (doc) -> console.log "#{ddoc._id} was saved",
  (reason) ->
    console.error "error saving #{ddoc._id}: " + reason
)

