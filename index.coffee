http = require('http')
fs = require('fs')
archiver = require('archiver')
Stream = require('stream')
superagent = require('superagent')

http.createServer((request, response)->
    response.writeHead(200, {
      'Content-Type': 'application/zip',
      'Content-disposition': 'attachment; filename=myFile.zip'
    })

    zip = archiver('zip')
    zip.pipe(response)
    for i in [1..2]
      zip
        .append(
          superagent.get('http://vjs.zencdn.net/v/oceans.mp4')
          , { name: "ocean#{i}.mp4" }
        )
    zip.finalize()

).listen(process.env.PORT || 5000)
