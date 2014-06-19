'use strict'

# "": "index"
# "client/:tuplespace/": "client"
# "client/:tuplespace/:view": "client"
# "client/": "client"
# "client/:tuplespace/settings": "settings"

define [
  'require'
  'app'
  'client'
  'views'
  'model'
  'backbone'
  'marionette'
], (require, app, Client, Views, Model, Backbone) ->
  App = require 'app'
  class Controller extends Backbone.Marionette.Controller
    to: (tuplespace)->
      username = window.localStorage.getItem("username")
      App.router.navigate "/#{username}/", true

    top: (tuplespace)->
      App.main.currentView.changeView()

    client: (tuplespace, viewname)->
      if !App.task?
        return App.router.navigate "/#{tuplespace}/", true
      App.main.currentView.changeView App.task

    settings: ->

    login: ->
      App.login.show new Views.Login()

  return Controller
