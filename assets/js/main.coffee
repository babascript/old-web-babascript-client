#/*global require*/
'use strict'

require.config
  shim:
    bootstrap:
      deps: ['jquery'],
      exports: 'jquery'
    marionette:
      deps: ['jquery', 'lodash', 'backbone']
      exports: 'Marionette'
    lodash:
      deps: ['jquery']
      exports: '_'
    socketio:
      exports: 'socketio'
    linda:
      deps: ['socketio', 'eventemitter']
      exports: 'linda'
    backbone:
      deps: ['jquery', 'lodash']
      exports: 'backbone'
    eventemitter:
      exports: 'eventemitter'
    client:
      deps: ['eventemitter']
      exports: 'client'

  paths:
    jquery: '../jquery/dist/jquery'
    backbone: '../backbone/backbone'
    marionette: '../marionette/lib/backbone.marionette'
    lodash: '../lodash/dist/lodash'
    underscore: '../underscore/underscore'
    bootstrap: '../sass-bootstrap/dist/js/bootstrap'
    moment: '../moment/moment'
    socketio: '../socket.io-client/dist/socket.io'
    eventemitter: '../event_emitter/event_emitter'
    router: './router'
    controller: './controller'
    linda: './linda-socket.io'
    push: './PushNotification'
    client: './client'
    app: './app'
    model: './model'
    views: './views'

require [
  'app'
  'router'
  'controller'
  'views'
  'backbone'
  'bootstrap'
], (App, Router, Controller, Views, Backbone) ->
  console.log App
  App.router = new Router
    controller: new Controller()

  App.start()
