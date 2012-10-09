__      = require '../../vendor/underscore'
log     = require '../../lib/logging'

T       = require('traits').Trait
cloning = require '../../lib/base/cloning'
objset  = require '../../lib/base/objset'


module.exports = T.object {
  proto: () ->
    THIS   = this
    result = Object.create Object.prototype, T({
      installProperty: (name) ->
        descr = {
          enumerable: true
          configurable: false
          get: () ->
            here = this
            while here
              log.info "here #{here}"
              val  = here._values[name]
              log.info "val #{val}"
              return val if val
              here = here.parent
            undefined
          set: (newValue) ->
            this._values[name] = newValue
        }
        Object.defineProperty this.proto, name, descr
    })
    result

  trait: (parent, childs) ->
    THIS   = this
    proto  = if parent then parent.proto else THIS.proto()
    result = T {
      _childs: objset.create childs
      _parent: parent
      _values: {}

      isBelow: (other) ->
        p = this.parent
        if p == other then true else  (if p then p.isBelow(other) else false)

      uproot: () ->
        this.parent = null

      hasChild: (c) ->
        this._childs.has(c)

      newRoot: () ->
        trait = THIS.trait(null)
        leaf  = Object.create this.proto, trait
        leaf

      newChild: () ->
        trait = THIS.trait(this)
        leaf  = Object.create this.proto, trait
        this._childs.add leaf
        leaf
    }
    result.proto   = {
      enumerable: false,
      get: () ->
        proto
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

  create: (childs = []) ->
    trait = this.trait(null, childs)
    Object.create trait.proto.get(), trait
}


