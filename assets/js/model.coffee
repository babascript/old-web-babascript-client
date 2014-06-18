'use strict'

define ['backbone'], (Backbone) ->

  class Task extends Backbone.Model

  class Tasks extends Backbone.Collection

  return {
    Task: Task
    Tasks: Tasks
  }
