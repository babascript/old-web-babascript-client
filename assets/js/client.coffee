'use strict'
define [
  'eventemitter'
  'linda'
  'socketio'
], (EventEmitter, LindaSocketIO, SocketIOClient) ->
  LindaSocketIOClient = window.Linda
  class Client extends EventEmitter  

    constructor: (@name, @options={}) ->
      super()
      @api = options?.manager || 'http://linda.babascript.org'
      socket = SocketIOClient.connect @api , {'force new connection': true, port: 80}
      @linda = new LindaSocketIOClient().connect socket
      @tasks = []
      @id = @getId()
      @data = {}
      @setFlag = true
      @loadingModules = []
      @modules = {}
      @linda.io.on "connect", =>
        @connect()
      setInterval =>
        if !@linda.io.socket.open
          @linda.io.socket.connect()
      , 10000
      return @

    connect: =>
      @_connect()

    _connect: =>
      @group = @linda.tuplespace @name
      @next()
      @broadcast()
      @unicast()
      @watchCancel()

    next: ->
      if @tasks.length > 0
        task = @tasks[0]
        format = task.format
        @emit "get_task", task
      if !@taked
        @taked = true
        @group.take {baba: "script", type: "eval"}, @getTask

    unicast: ->
      t = {baba: "script", type: "unicast", unicast: @id}
      @group.read t, (err, tuple)=>
        @getTask err, tuple
        @group.watch t, @getTask

    broadcast: ->
      t = {baba: "script", type: "broadcast"}
      cid = ""
      timeoutId = setTimeout =>
        @group.cancel cid
        @group.watch t, @getTask
      , 2000
      cid = @group.read t, (err, tuple) =>
        return if err
        clearInterval timeoutId
        @getTask err, tuple
        @group.watch t, @getTask


    watchCancel: ->
      @group.watch {baba: "script", type: "cancel"}, (err, tuple) =>
        _.each @tasks, (task, i) =>
          if task.cid is tuple.data.cid
            @tasks.splice i, 1
            if i is 0
              @emit "cancel_task", 'cancel'
              @next()

    cancel: (cause) ->
      task = @tasks.shift()
      cid = task.cid
      tuple =
        baba: "script"
        type: "cancel"
        cid: cid
        value: cause
      @group.write tuple
      @next()

    returnValue: (value, options={}) ->
      task = @tasks.shift()
      tuple =
        baba: "script"
        type: "return"
        value: value
        cid: task.cid
        worker: options.worker || @name
        options: options
        name: @name
        _task: task
      @group.write tuple
      if task.type is 'eval'
        @taked = false
      @next()

    watchAliveCheck: ->
      @group.watch {baba: "script", type: "aliveCheck"}, (err, tuple)=>
        @group.write {baba: "script", alive: true, id: @id}

    getTask: (err, tuple)=>
      return err if err
      console.log tuple
      @tasks.push tuple.data
      @emit "get_task", tuple.data

    getId: ->
      return "#{Math.random()*10000}_#{Math.random()*10000}"

    set: (name, mod) =>
      @loadingModules.push {name: name, body: mod}
      @__set()

    __set: =>
      if @loadingModules.length is 0
        @next()
      else
        if @setFlag
          @setFlag = false
          mod = @loadingModules.shift()
          name = mod.name
          mod.body.load @, =>
            setTimeout =>
              @modules[name] = mod
              @setFlag = true
              @__set()
            , 100