'use strict'

path = require 'path'
http = require 'http'
express = require 'express'

pkg = require path.resolve 'package.json'
app = module.exports = express()

app.set 'view engine', 'jade'
# app.use (require 'morgan')('dev') if 'off' isnt process.env.NODE_LOG
app.use express.static path.resolve 'bower_components'
app.use express.static path.resolve 'dist'
# app.use (require 'body-parser')()
# app.use (require 'method-override')()
# app.use (require 'cookie-parser')()

app.listen(3000)
