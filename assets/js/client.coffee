'use strict'
define [
  'eventemitter'
  'linda'
  'socketio'
], (EventEmitter, LindaSocketIO, SocketIOClient) ->
  LindaSocketIOClient = window.Linda
  class UserAttributes extends EventEmitter
    data: {}
    isSyncable: false
    constructor: (@linda) ->
      super()

    get: (key) ->
      return if !key?
      return @data[key]

    __syncStart: (_data) ->
      return if !_data?
      @name = _data.username
      __data = null
      for key, value of _data.attribute
        if !@get(key)?
          @set key, value
        else
          __data = {} if !__data?
          __data[key] = value
      @isSyncable = true
      @emit "get_data", @data
      @ts = @linda.tuplespace(@name)
      @ts.watch {type: 'userdata'}, (err, result) =>
        return if err
        {key, value, username} = result.data
        if username is @name
          v = @get key
          if v isnt value
            @set key, value, {sync: false}
            @emit "change_data", @data
      if __data?
        for key, value of __data
          @sync key, value

    sync: (key, value) =>
      @ts.write {type: 'update', key: key, value: value}

    set: (key, value, options={sync: false}) ->
      return if !key? or !value?
      if options.sync is true and @isSyncable is true
        if @get(key) isnt value
          @sync key, value
      else
        @data[key] = value


  class Client extends EventEmitter

    constructor: (@name, @options={}) ->
      super()
      @api = options?.manager || 'http://linda.babascript.org'
      socket = SocketIOClient.connect @api , {'force new connection': true, port: 80}
      @linda = new LindaSocketIOClient().connect socket
      @tasks = []
      @attributes = new UserAttributes @linda
      @id = @getId()
      @linda.io.on "connect", =>
        @connect()
      setInterval =>
        if !@linda.io.socket.open
          @linda.io.socket.connect()
      , 10000
      return @

    connect: =>
      if !@options?.manager?
        @_connect()
      else
        {host, port} = @linda.io.socket.options
        $.ajax
          type: "GET"
          url: "http://#{host}:#{port}/api/user/#{@name}"
        .done (res) =>
          @attributes.__syncStart res
        .always =>
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
        @group.write
          baba: 'script'
          type: 'report'
          value: 'taked'
          tuple: task
      else
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
    cancel: ->
      task = @tasks.shift()
      cid = task.cid
      tuple =
        baba: "script"
        type: "cancel"
        cid: cid
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
      @next()

    watchAliveCheck: ->
      @group.watch {baba: "script", type: "aliveCheck"}, (err, tuple)=>
        @group.write {baba: "script", alive: true, id: @id}

    getTask: (err, tuple)=>
      return err if err
      @tasks.push tuple.data
      @emit "get_task", tuple.data

    getId: ->
      return "#{Math.random()*10000}_#{Math.random()*10000}"


  if window?
    window.BabascriptClient = Client
  else if module?.exports?
    module.exports = Client
