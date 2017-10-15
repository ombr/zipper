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
    for i in [1..1]
      zip
        .append(
          superagent.get("https://assets.imgix.net/examples/leaves.jpg?w=400#{i}&dl=medium.jpg")
          , { name: "image#{i}.jpg" }
        )
    zip.finalize()

).listen(process.env.PORT || 5000)
