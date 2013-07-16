# Storage provides a simple-to-use interface to the CouchDB storage
#
# var stor = require('./lib/storage')
# var dbc = new stor.Storage()

couchdb = require('then-couchdb')

class Storage
  constructor: ->
    # TODO:
    @db = couchdb.createClient('http://localhost:5984/node-hockey')
    false

  # method to save document and return a promise
  save: (doc) ->
    @db.save(doc)


exports.Storage = Storage
