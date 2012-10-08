__      = require '../../vendor/underscore'
log     = require '../../lib/logging'

T       = require('traits').Trait
cloning = require '../../lib/base/cloning'
objset  = require '../../lib/base/objset'


module.exports = T.object {
  trait: (parent, childs) ->
    THIS   = this
    result = T {
      _childs: objset.create childs
      _parent: parent

      isBelow: (other) ->
        p = this.parent
        if p == other then true else  (if p then p.isBelow(other) else false)

      uproot: () ->
        this.parent = null

      hasChild: (c) ->
        this._childs.has(c)

      newChild: () ->
        child = Object.create Object.prototype, THIS.trait(this)
        this._childs.add child
        child
    }
    result.root    = {
      enumerable: false
      get: () ->
        p = this.parent
        (p && p.root) || this
    }
    result.parent = {
      enumerable: false
      get: () ->
        p = this._parent
        if (p && p._childs.has(this)) then p else null
      set: (newParent) ->
        return if this._parent == newParent
        throw new Error('Cyclic parent chain in leafy') if (newParent && newParent.isBelow(this))
        p = this._parent
        p._childs.remove(this) if (p && p._childs.has(this))
        newParent._childs.add(this) if newParent
        this._parent = newParent
    }
    result.childs = { enumerable: false, get: () -> this._childs.elems }
    result

  create: (childs = []) -> Object.create Object.prototype, this.trait(null, childs)
}


