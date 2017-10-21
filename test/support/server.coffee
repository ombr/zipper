http = require('http')

exports.server = (content)->
  server = http.createServer (req, res)->
    res.writeHead(200, { 'Content-Type': 'text/plain' })
    res.end(content)
  server.listen(8001)
  return {
    url: 'http://localhost:8001'
    stop: (callback)->
      server.close callback
  }

