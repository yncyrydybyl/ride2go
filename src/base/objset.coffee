T       = require('traits').Trait
cloning = require '../../lib/base/cloning'

protoTrait = T {
  has: (e) -> this._items.indexOf(e) >= 0
  add: (e) -> this._items.push(e) if !this.has(e)
  remove: (e) ->
    pos = this._items.indexOf e
    this._items.splice pos, 1 if pos >= 0
    this
}

protoTrait.elems = { enumerable: false, get: () -> this._items.slice 0 }
protoTrait.size  = { enumerable: false, get: () -> this._items.length }

proto = Object.create Object.prototype, protoTrait
proto.freeze

module.exports = T.object {
  protoTrait: protoTrait

  createTrait: (traitF, items) ->
    THIS         = this
    trait        = T { cloneTrait: () -> THIS.createTrait traitF, this.elems }
    trait._items = { enumerable: false, writable: false, value: items }
    trait        = T.compose cloning.trait, trait
    (traitF && traitF(trait)) || trait

  create: (childs = [], traitF = null) ->
    this.create_ proto, childs, traitF

  create_: (proto, childs = [], traitF = null) ->
    T.create proto, this.createTrait(traitF, childs)
}

