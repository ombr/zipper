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
    for i in [1..100]
      zip
        .append(
          superagent.get('https://picsum.photos/1000/1000')
          , { name: "image#{i}.jpg" }
        )
    zip.finalize()

).listen(process.env.PORT || 5000)
