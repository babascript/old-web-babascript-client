'use strict'

define [
  'require'
  'client'
  'views'
  'model'
  'backbone'
  'marionette'
], (require, Client, Views, Model, Backbone, Marionette) ->
  client = require 'client'

  App = new Marionette.Application()

  App.addRegions
    'header': '#header'
    'main': '#main'
    'settings': '#settings'
    'login': '#login'
    'error': '#error'

  App.API = 'http://linda.babascript.org'

  App.addInitializer ->
    App.header.close()
    App.main.close()
    App.settings.close()
    App.login.close()
    App.error.close()

    header = new Views.Header()
    App.header.show header

    App.task = null
    main = new Views.Main
      model: App.task
    App.main.show main

    username = window.localStorage.getItem "username"
    if !username?
      path = "settings"
    else
      path = "#{username}"
      header.ui.name.html username

      App.client ?= new Client username,
        manager: App.API
      App.client.on "get_task", (task) ->
        console.log 'get_task'
        console.log task
        App.task = new Model.Task
          key: task.key
          format: task.format || 'boolean'
          description: task.description || ''
          list: task.list || []
        setTimeout ->
          App.router.navigate "/#{username}/#{task.format}", true
        , 500
      App.client.on "cancel_task", ->
        console.log 'cancel'
        App.router.navigate "/#{username}/", true
    Backbone.history.start()
    App.router.navigate path, true

    # managerFlag = false
    # path = ""
    # username = ""
    # $.ajax
    #   type: "GET"
    #   xhrFields:
    #     withCredentials: true
    #   url: "#{App.API}/api/session"
    # .done (res) ->
    #   username = res.username
    #   token = res.token
    #   App.token = token
    #   App.username = username
    #   App.type = "manager"
    #   console.log App.token
    #   path = "/#{username}/"
    #   header.ui.name.html username
    #   managerFlag = true
    # .error (error) ->
    #   if error.status is 401
    #     path = "login"
    #   else
    #     console.log 'normal linda setup'
    #     username = window.localStorage.getItem 'username'
    #     if username?
    #       path = "/#{username}/"
    #       header.ui.name.html username
    #     else
    #       path = "/settings"
    # .always ->
    #   Backbone.history.start()
    #   App.router.navigate path, true

  return App
