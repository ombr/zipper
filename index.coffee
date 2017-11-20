express = require('express')
fs = require('fs')
archiver = require('archiver')
Stream = require('stream')
superagent = require('superagent')
async = require('async')
Throttle = require('throttle')
jwt = require('jsonwebtoken')
app = express()
bodyParser = require('body-parser')

app.get '/', (req, res)->
  res.send 'Hi, I am zipper, ready for zipping !'

app.use(bodyParser.urlencoded(extended: true))
app.use(bodyParser.json())
app.post '/', (req, res)->
  token = req.body.token
  jwt.verify(token, process.env.API_SECRET || 'secret', {}, (err, decoded)->
    if err
      res.status 401
      res.send 'Invalid JWT token'
      return
    filename = 'zip.zip'

    res.writeHead(200, {
      'Content-Type': 'application/zip',
      'Content-disposition': "attachment; filename=#{filename}"
    })

    zip = archiver('zip')
    zip.pipe(res)

    files = decoded.files
    if files.length == 0
      zip.finalize()
      return

    q = async.queue((task, callback)->
      download = superagent.get(task.url).pipe(new Throttle(500*1024))
      zip.append(download, { name: task.filename })
      download.on 'end', ->
        callback()
    , 1)
    for file in files
      q.push file
    q.drain = ->
      zip.finalize()
  )

app_port = process.env.PORT || 5000
app.listen app_port, ->
  console.log 'Zipper started on port ' + app_port

# for i in `seq 1 10`; do wget -O $i.zip http://67.205.173.146:5000/ & done
# for i in `seq 1 10`; do wget -O $i.zip http://54.152.24.116:5000/ & done
