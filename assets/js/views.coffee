
'use strict'
define [
  'require'
  'app'
  'model'
  'backbone'
  'marionette'
], (require, App, Model, Backbone, Marionette) ->
  App = {}
  console.log Backbone.Marionette
  class BaseView extends Marionette.ItemView
    tagName: "div"

    initialize: ->

    events:
      "touchstart button": "active"
      "touchend button": "normal"
      'submit': "submitcancel"

    active: (e) ->
      $(e.currentTarget).addClass 'active'
    normal: (e) ->
      $(e.currentTarget).removeClass 'active'

    submitcancel: ->
      return false

    returnValue: (value, option={})->
      app = require('app')
      app.task = null
      app.client.emit 'cancel_task'
      app.client.returnValue value, option
      window.plugins?.toast?.show "返り値: #{value}", "short", "center"

    cancel: ->
      app = require('app')
      console.log app
      app.task = null
      app.client.emit 'cancel_task'
      app.client.cancel()

  class HeaderView extends Marionette.ItemView
    template: '#header-template'
    className: 'container'
    ui:
      cancel: 'a.cancel-button'
      setting: 'a.settings-button'
      logout: 'a.logout'
      name: 'a.header-title'
    events:
      "click @ui.logout": 'logout'
      'click @ui.cancel': 'cancelTask'
      'click @ui.setting': 'settings'

    initialize: ->

    cancelTask: ->
      app = require('app')
      app.task = null
      app.client.emit 'cancel_task'
      require('app').client.cancel()

    settings: ->
      require('app').settings.show new SettingsView()

    logout: ->
      $.ajax
        type: "DELETE"
        url: "#{require('app').API}/api/session/logout"
        xhrFields:
          withCredentials: true
      .always ->
        window.location.reload()

  class SettingsView extends Marionette.ItemView
    template: '#settings-template'
    className: 'modal-dialog'
    ui:
      username: 'input#username'
      update: 'button.update'
      logout: 'button.logout'
      close: 'button.close'
    events:
      "click @ui.update": 'update'
      "click @ui.logout": 'logout'
      "click @ui.close": 'close'
    update: ->
      username = @ui.username.val()
      return if !username? or username.length is 0
      window.localStorage.setItem "username", username
      @$el.modal()
      @logout()
      window.location.reload()
    logout: ->
      $.ajax
        type: "DELETE"
        url: "#{require('app').API}/api/session/logout"
        xhrFields:
          withCredentials: true
      .always ->
        window.location.reload()
    close: ->
      # require('app').settings.close()
      # @$el.modal()

  class LoginView extends Marionette.ItemView
    template: '#login-template'
    className: 'modal-dialog'
    ui:
      username: 'input#username'
      password: 'input#password'
      login: 'button.login'
      signup: 'button.signup'
    events:
      "click @ui.login": 'login'
      "click @ui.signup": 'signup'
    login: ->
      username = @ui.username.val()
      password = @ui.password.val()
      $.ajax
        type: "POST"
        url: "#{require('app').API}/api/session/login"
        data:
          username: username
          password: password
        xhrFields:
          withCredentials: true
      .done (res)=>
        window.localStorage.setItem "username", username
        require('app').router.navigate "/", true
        window.location.reload()
      .error ->
        window.alert "invalid username or password "
    signup: ->
      console.log 'singnup'
      username = @ui.username.val()
      password = @ui.password.val()
      $.ajax
        type: "POST"
        url: "#{require('app').API}/api/user/new"
        data:
          username: username
          password: password
        xhrFields:
          withCredentials: true
      .done (res)=>
        window.localStorage.setItem "username", username
        $.ajax
          type: "POST"
          url: "#{require('app').API}/api/session/login"
          data:
            username: username
            password: password
          xhrFields:
            withCredentials: true
        .done (res) ->
          require('app').router.navigate "/", true
          window.location.reload()
        .error (error)->
          window.alert "invalid username or password "
      .error ->
        window.alert "invalid username or password "

  class MainView extends Marionette.Layout
    template: '#main-template'
    regions:
      returnview: '#returnview'
    initialize: ->
    changeView: (model) ->
      format = model?.get 'format'
      viewClass = switch format
        when "", "index"
          NormalView
        when "boolean", "bool"
          BooleanView
        when "string"
          StringView
        when "list"
          ListView
        when "number", "int"
          NumberView
        when "void"
          VoidView
        when "camera"
          CameraView
        else
          NormalView
      @returnview.close()
      @returnview.show new viewClass {model: model}

  class NormalView extends BaseView
    template: '#normal-template'
    className: 'normal-page'

  class BooleanView extends BaseView
    template: '#boolean-template'
    className: 'boolean-page'
    ui:
      truebutton: 'button.true'
      falsebutton: 'button.false'
    events:
      'click @ui.truebutton': 'returntrue'
      'click @ui.falsebutton': 'returnfalse'
    returntrue: ->
      @returnValue true
    returnfalse: ->
      @returnValue false

  class StringView extends BaseView
    template: '#string-template'
    className: 'string-page'
    ui:
      input: 'input.string-value'
      button: 'button'
    events:
      'click @ui.button': 'returnString'
    returnString: ->
      @returnValue @ui.input.val()

  class ListView extends BaseView
    template: '#list-template'
    className: 'list-page'
    ui:
      select: 'select'
      button: 'button'
    events:
      'click @ui.button': 'returnSelect'
    returnSelect: ->
      value = @ui.select.val()
      console.log value
      @returnValue value

  class NumberView extends BaseView
    template: '#number-template'
    className: 'number-page'
    ui:
      input: 'input.number-value'
      button: 'button'
    events:
      'click @ui.button': 'returnNumber'
    returnNumber: ->
      @returnValue @ui.input.val()

  class VoidView extends BaseView
    template: '#void-template'
    className: 'void-page'
    ui:
      button: 'button.void'
    events:
      'click @ui.button': 'returnVoid'
    returnVoid: ->
      @returnValue 'true'

  class Task extends Backbone.Model

  initialize: ->
    @$el.html @template()

  class ThrowErrorView extends BaseView
    tempalte: '#throw-error-template'
    className: 'throw-error-page'
    # ui


  return {
    Header: HeaderView
    Base: BaseView
    Main: MainView
    Normal: NormalView
    Boolean: BooleanView
    String: StringView
    List: ListView
    Number: NumberView
    Void: VoidView
    Task: Task
    Login: LoginView
    Settings: SettingsView
  }
