'use strict'

define [
  'require'
  'client'
  'views'
  'model'
  'backbone'
  'marionette'
], (require, client, Views, Model, Backbone, Marionette) ->
  client = require 'client'

  App = new Marionette.Application()

  App.addRegions
    'header': '#header'
    'main': '#main'
    'settings': '#settings'
    'login': '#login'

  # App.API = 'http://153.121.44.172:9080'
  App.API = 'http://linda.babascript.org'
  # App.API = 'http://133.27.75.135:9080'

  App.addInitializer ->
    console.log App
    App.header.close()
    App.main.close()
    App.settings.close()
    App.login.close()

    header = new Views.Header()
    App.header.show header

    App.task = null
    main = new Views.Main
      model: App.task
    App.main.show main

    managerFlag = false
    path = ""
    username = ""
    $.ajax
      type: "GET"
      xhrFields:
        withCredentials: true
      url: "#{App.API}/api/session"
    .done (res) ->
      username = res.username
      token = res.token
      App.token = token
      App.username = username
      App.type = "manager"
      console.log App.token
      path = "/#{username}/"
      header.ui.name.html username
      managerFlag = true
    .error (error) ->
      if error.status is 401
        path = "login"
      else
        console.log 'normal linda setup'
        username = window.localStorage.getItem 'username'
        if username?
          path = "/#{username}/"
          header.ui.name.html username
        else
          path = "/settings"
    .always ->
      Backbone.history.start()
      App.router.navigate path, true

      if navigator.geolocation? and managerFlag
        console.log "geolocation!!"
        cid = setInterval ->
          navigator.geolocation.getCurrentPosition (pos) ->
            console.log pos
            lat = pos.coords.latitude
            lng = pos.coords.longitude
            opt = {sync: true}
            App.client.attributes.set 'latitude', lat, opt
            App.client.attributes.set 'longitude', lng, opt
          , (err) ->
        , 10000

      notificationId = window.localStorage.getItem "notificationId"
      if device?.platform
        pushNotification = window.plugins.pushNotification
        if device.platform is 'android' or device.platform is 'Android'
          pushNotification.register (result) ->
            console.log 'result is ok'
            console.log result
          , (error) ->
            console.log 'error!'
            console.log error
          , {senderID: "438189273887", ecb: "onNotification"}
        else
          pushNotification.register (token) ->
            # token handler!
            # ここでmanagerに通知
            console.log "register!"
            $.ajax
              type: "POST"
              url: "#{App.API}/api/user/#{username}/device"
              data:
                type: 'ios'
                token: token
            .done ->
              console.log 'device register'
            .error ->
              console.log 'error! device register'
            console.log "success! token is #{token}"
          , (error) ->
            console.log "error! error is #{error}"
          , {badge: true, sound: true, alert: true, ecb: "onNotificationAPN"}
        window.onNotification = (notification)->
          if notification.event is 'registered'
            $.ajax
              type: "POST"
              url: "#{App.API}/api/user/#{username}/device"
              data:
                type: 'android'
                token: notification.regid
            .done ->
              console.log 'device register'
            .error ->
              console.log 'error! device register'
            .always ->
          else
            console.log notification
        window.onNotificationAPN = (e) ->
          console.log e

  return App
