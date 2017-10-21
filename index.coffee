http = require('http')
fs = require('fs')
archiver = require('archiver')
Stream = require('stream')
superagent = require('superagent')
async = require('async')
Throttle = require('throttle')
jwt = require('jsonwebtoken')

http.createServer((request, response)->
    response.writeHead(200, {
      'Content-Type': 'application/zip',
      'Content-disposition': 'attachment; filename=myFile.zip'
    })

    zip = archiver('zip')
    zip.pipe(response)

    q = async.queue((task, callback)->
      console.log task.url
      download = superagent.get(task.url).pipe(new Throttle(500*1024))
      zip.append(download, { name: task.name })
      download.on 'end', ->
        console.log '.'
        callback()
    , 1)

    q.drain = ->
      zip.finalize()

    for i in [1..1]
      q.push {
        url: "https://assets.imgix.net/examples/leaves.jpg?w=4#{i}&dl=medium.jpg"
        name: "image#{i}.jpg"
      }

    # q.drain() if q.empty
).listen(process.env.PORT || 5000)

# for i in `seq 1 10`; do wget -O $i.zip http://67.205.173.146:5000/ & done
# for i in `seq 1 10`; do wget -O $i.zip http://54.152.24.116:5000/ & done
