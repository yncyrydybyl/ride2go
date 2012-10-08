T       = require('traits').Trait
cloning = require '../../lib/base/cloning'

module.exports = (items = []) ->
  ctor  = this
  trait = T {
    has: (e) ->
      items.indexOf(e) >= 0

    add: (e) ->
      items.push(e) if !this.has(e)
      this

    remove: (e) ->
      pos = items.indexOf e
      items.splice pos, 1 if pos >= 0
      this

    cloneTrait: () ->
      ctor.call(ctor, this.elems)
  }
  trait.elems = { get: () -> items.slice 0 }
  trait.size  = { get: () -> items.length }
  T.compose cloning, trait

module.exports.create = (args...) ->
  T.create Object.prototype, this.apply(this, args)

