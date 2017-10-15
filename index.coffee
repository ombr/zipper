http = require('http')
fs = require('fs')
archiver = require('archiver')
Stream = require('stream')
superagent = require('superagent')
async = require('async')

http.createServer((request, response)->
    response.writeHead(200, {
      'Content-Type': 'application/zip',
      'Content-disposition': 'attachment; filename=myFile.zip'
    })

    zip = archiver('zip')
    zip.pipe(response)

    q = async.queue((task, callback)->
      console.log task.url
      download = superagent.get(task.url)
      zip.append(download, { name: task.name })
      download.on 'end', ->
        console.log '.'
        callback()
    , 1)

    q.drain = ->
      zip.finalize()

    for i in [1..100]
      q.push {
        url: "https://assets.imgix.net/examples/leaves.jpg?w=400#{i}&dl=medium.jpg"
        name: "image#{i}.jpg"
      }
).listen(process.env.PORT || 5000)
