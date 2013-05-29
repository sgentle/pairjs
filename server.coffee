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

cwd = process.cwd()
localPath = (_path) -> path.resolve(_path).indexOf(cwd) is 0

server = express()


options =
  db:
    type: "none"

  sockjs: {}

  auth: (client, action) ->
    # This auth handler rejects any ops bound for docs starting with 'readonly'.
    if action.name is "submit op" and !localPath decodeURIComponent action.docName
      action.reject()
    else
      action.accept()

listDir = (req, res, next) ->
  fs.stat req.params.path, (err, stat) ->
    return res.send 404 if err and req.route.path.indexOf('/view') is 0
    return next() unless stat?.isDirectory()

    data = []
    data.push "<html><head></head><body><h1>File listing</h1><table>"
    data.push "<tr><th>Name</th></tr>"
    fs.readdir req.params.path, (err, files) ->
      for file in files
        fullpath = path.join req.params.path, file
        data.push "<tr><td>#{file}</td><td><a href='/edit/#{fullpath}'>edit</a></td><td><a href='/view/#{fullpath}'>view static</a></td><td><a href='/live/#{fullpath}'>view live</a></td></tr>"
      data.push "</table></body></html>"
      res.send data.join ''

server.get "/", (req, res) -> res.redirect "/view/"


checkPath = (req, res, next) ->
  req.params.path = path.normalize req.params[0]
  return res.send 403 unless localPath req.params.path
  next()

code = fs.readFileSync(__dirname + '/code.html', 'utf8')
live = fs.readFileSync(__dirname + '/live.html', 'utf8')

server.get "/edit/*", checkPath, listDir, (req, res, next) -> res.send code

server.get "/live/*", checkPath, listDir, (req, res, next) -> res.send live

server.get "/view/*", checkPath, listDir, (req, res, next) ->
  docName = encodeURIComponent req.params.path
  server.model.getSnapshot docName, (err, data) ->
    if err
      res.send 500, err.message
    else
      res.send data.snapshot

server.use express.static(__dirname + '/static')

httpServer = sharejs.server.attach server, options

model = server.model

console.log "Loading files from '#{_path or "."}'..."

files = require('findit').sync '.'
numDone = 0
for file in files then do (file) ->
  return numDone++ if fs.statSync(file).isDirectory()
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
    return console.log("dropped empty first op") if opData.version is 1 and snapshot is ''

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

