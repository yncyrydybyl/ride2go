T       = require('traits').Trait
cloning = require '../../lib/base/cloning'

module.exports = T.object {
  createTrait: (traitF, items) ->
    THIS   = this
    TRAIT  = T {
      has: (e) -> this._items.indexOf(e) >= 0
      add: (e) -> this._items.push(e) if !this.has(e)
      remove: (e) ->
        pos = this._items.indexOf e
        this._items.splice pos, 1 if pos >= 0
        this
      cloneTrait: () -> THIS.createTrait traitF, this.elems
    }
    TRAIT._items     = { enumerable: false, writable: false, value: items}
    TRAIT.elems      = { enumerable: false, get: () -> items.slice 0 }
    TRAIT.size       = { enumerable: false, get: () -> items.length }
    TRAIT            = T.compose cloning.trait, TRAIT
    (traitF && traitF(TRAIT)) || TRAIT

  create: (childs = [], traitF = null) ->
    this.create_ Object.prototype, childs, traitF

  create_: (proto, childs = [], traitF = null) ->
    T.create proto, this.createTrait(traitF, childs)
}

