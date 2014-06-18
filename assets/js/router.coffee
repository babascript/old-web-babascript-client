'use strict'


define ['backbone', 'marionette'], (Backbone) ->
  class Router extends Backbone.Marionette.AppRouter
    appRoutes:
      "": "to"
      "login": "login"
      "settings": "settings"
      ":tuplespace": "to"
      ":tuplespace/": "top"
      ":tuplespace/:view": "client"

  return Router
