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
      if !App.client?
        App.client ?= new Client tuplespace,
          manager: App.API
          query:
            token: App.token
        App.client.attributes.on "change_data", (attr) ->
          console.log attr
        App.client.on "get_task", (task) ->
          console.log 'get_task'
          console.log task
          App.task = new Model.Task
            key: task.key
            format: task.format || 'boolean'
            description: task.description || ''
            list: task.list || []
          setTimeout ->
            App.router.navigate "/#{tuplespace}/#{task.format}", true
          , 500
          navigator.notification?.vibrate 1000
        App.client.on "cancel_task", ->
          console.log 'cancel'
          App.router.navigate "/#{tuplespace}/", true

      App.main.currentView.changeView()

    client: (tuplespace, viewname)->
      if !App.task?
        return App.router.navigate "/#{tuplespace}/", true
      App.main.currentView.changeView App.task

    settings: ->

    login: ->
      App.login.show new Views.Login()

  return Controller
