assert = require('assert')
jwt = require('jsonwebtoken')
superagent = require('superagent')
URL = require('url').URL
# server = require('test/support/server.coffee')


describe 'Zipper', ()->
  it 'Returns a correct zip file', (done)->
    this.timeout(15000)
    url = new URL(process.env.ZIPPER_URL || 'http://username:secret@localhost:5000/v1')
    jwt.sign(
      { files: [], iss: url.username },
      url.password,
      (err, token)->
        url.username = ''
        url.password = ''
        console.log 'POST', url.href, token
        superagent
          .post(url.href)
          .send({zip: token})
          .accept('zip')
          .end (err, res)->
            console.log err, res
            console.log res.body
            assert.equal(res.status, 200)
            done()

    )

