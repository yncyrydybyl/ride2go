T       = require('traits').Trait
cloning = require '../../lib/base/cloning'

module.exports = T.object {
  trait: (items = []) ->
    THIS   = this
    result = T {
      has: (e) -> this._items.indexOf(e) >= 0
      add: (e) -> this._items.push(e) if !this.has(e)
      remove: (e) ->
        pos = this._items.indexOf e
        this._items.splice pos, 1 if pos >= 0
        this
      cloneTrait: () -> THIS.trait this.elems
    }
    result._items     = { enumerable: false, writable: false, value: items}
    result.elems      = { enumerable: false, get: () -> items.slice 0 }
    result.size       = { enumerable: false, get: () -> items.length }
    result            = T.compose cloning.trait, result
    result

  create: (args...) -> T.create Object.prototype, this.trait.apply(this, args)
}

