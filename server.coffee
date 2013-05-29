# This is a simple example sharejs server which hosts the sharejs
# examples in examples/.
#
# It demonstrates a few techniques to get different application behaviour.
fs      = require 'fs'
path    = require 'path'
express = require 'express'
sharejs = require 'share'
dir     = require 'node-dir'
argv = require('optimist')
    .usage('Usage: $0 [path]')
    .options
      p: alias: 'port', describe: "Port to listen on", default: 8000
    .argv

[_path] = argv._

process.chdir path.resolve(_path) if _path

server = express()


options =
  db:
    type: "none"

  sockjs: {}

  auth: (client, action) ->
    
    # This auth handler rejects any ops bound for docs starting with 'readonly'.
    if action.name is "submit op" and action.docName.match(/^readonly/)
      action.reject()
    else
      action.accept()

# Attach the sharejs REST and Socket.io interfaces to the server

code = fs.readFileSync(__dirname + '/code.html', 'utf8')

server.get "/edit/*", (req, res, next) ->
  res.send code

server.use express.static(__dirname + '/static')

#httpServer = require('http').createServer server
httpServer = sharejs.server.attach server, options

model = server.model

console.log "Loading files from '#{_path}'..."
dir.files '.', (err, files) ->
  throw err if err
  numDone = 0
  for file in files
    doc = encodeURIComponent(file)
    model.create doc, 'text', (err) ->
      throw err if err
      model.applyOp doc, v: 0, op: [{p:0, i: fs.readFileSync(file, 'utf8')}], (err, op) ->
        throw err if err
        console.log "Loaded", file
        numDone++
        done() if numDone == files.length

writing = {}

done = ->
  model.on 'applyOp', (docName, opData, snapshot, oldsnapshot) ->
    alreadyWriting = writing[docName]?
    writing[docName] = snapshot
    return if alreadyWriting
    setTimeout ->
      fname = decodeURIComponent(docName)
      fs.writeFile fname, writing[docName], 'utf8', (err) ->
        if err
          console.log "Error writing", fname
        else
          console.log "Wrote", fname

      delete writing[docName]
    , 1000


  httpServer.listen argv.port

  console.log "Server running on http://localhost:" + argv.port
  process.title = "pearjs"

