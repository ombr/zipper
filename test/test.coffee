assert = require('assert')
jwt = require('jsonwebtoken')
superagent = require('superagent')
URL = require('url').URL
unzip = require 'unzip'
# server = require('test/support/server.coffee')

zipper_token = (payload, callback)->
  url = new URL(process.env.ZIPPER_URL || 'http://username:secret@localhost:5000/v1')
  payload.iss = url.username
  jwt.sign(payload, url.password, callback)

zipper_url = ()->
  url = new URL(process.env.ZIPPER_URL || 'http://username:secret@localhost:5000/v1')
  url.username =''
  url.password =''
  url.href

describe 'Zipper', ()->
  it 'refuse a request with an invalid token', (done)->
    superagent
      .post(zipper_url())
      .send({token: 'invalid_token'})
      .accept('zip')
      .end (err, res)->
        assert.equal(res.status, 401)
        done()
    return

  it 'Returns a correct zip file', (done)->
    this.timeout(15000)
    zipper_token({ files: [] }, (err, token)->
      superagent
        .post(zipper_url())
        .send({token: token})
        .accept('zip')
        .end (err, res)->
          assert.equal(res.status, 200)
          done()
    )

  it 'Returns a correct zip with a file from internet', (done)->
    this.timeout(15000)
    zipper_token({ files: [ { url: 'https://s3.amazonaws.com/super-zipper-test/zipper.txt', filename: 'zipper.txt' }] }, (err, token)->
      superagent
        .post(zipper_url())
        .send({token: token})
        .accept('zip')
        .pipe(unzip.Parse())
        .on 'entry', (entry)->
          if entry.path == 'zipper.txt'
            res=''
            entry.on 'data', (c)->
              res += c
            entry.on 'end', ->
              assert.equal(res, "Hello from internet !\n")
              done()
          else
            entry.autodrain()
    )
