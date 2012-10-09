__      = require '../../vendor/underscore'
log     = require '../../lib/logging'

T       = require('traits').Trait
cloning = require '../../lib/base/cloning'
objset  = require '../../lib/base/objset'


module.exports = T.object {
  createProtoTrait: (traitF) ->
    THIS   = this
    result = T {
      registerProperty: (name) ->
        this._register.add name

      hasRegisteredProperty: (name) ->
        this._register.has(name)

      installProperty: (name) ->
        this.registerProperty name
        if ! this._installed.has(name)
          descr = {
            enumerable: true
            configurable: false
            get: () -> this.getProperty name
            set: (newValue) -> this.setProperty name, newValue
          }
          Object.defineProperty this.__proto__, name, descr
          this._installed.add name

      hasInstalledProperty: (name) ->
        this._register.has(name)

      installMissingProperties: () ->
        this.installProperty(name) for name in this.registeredProperties

      getPropertyOwner: (name) ->
        return undefined if !this.hasRegisteredProperty(name)
        here = this
        while here
          return here if here.hasLocal(name)
          here = here.parent
        here

      getProperty: (name) ->
        owner = this.getPropertyOwner name
        if owner then owner.getLocal(name) else undefined

      setProperty: (name, value) ->
        result = this.trySetLocal name, value
        if result == undefined
          throw new Error("Unregistered property #{name}")
        if result
          throw new Error("Conflict")
        null
    }
    result.registeredProperties = { enumerable: true, get: () -> this._register.elems }
    result.installedProperties  = { enumerable: true, get: () -> this._installed.elems }
    result._register  = { writable: false, value: objset.create() }
    result._installed = { writable: false, value: objset.create() }
    (traitF && traitF(result)) || result

  createTrait: (traitF, proto, parent, childs) ->
    THIS   = this
    result = T {
      isBelow: (other) ->
        p = this.parent
        if p == other then true else  (if p then p.isBelow(other) else false)

      isRoot: () ->
        this.parent == null

      isChild: () ->
        ! this.isRoot()

      uproot: () ->
        this.parent = null

      hasLocal: (name) ->
        this._values[name] != undefined

      hasChild: (c) ->
        this._childs.has(c)

      getLocal: (name) ->
        this._values[name]

      removeLocal: (name) ->
        delete this._values[name]

      trySetLocal: (name, value) ->
        throw new Error("undefined value") if value == undefined
        if this.hasLocal(name)
           this._values[name] = value
           null
        else
          owner = this.getPropertyOwner name
          if owner == null
            this._values[name] = value
            null
          else
            owner

      setLocal: (name, value) ->
        owner = trySetLocal name, value
        throw new Error("Attempt to set non-local property #{name}") if owner
        throw new Error("Unregistered property #{name}") if owner == undefined
        null

      newRoot: () ->
        trait = THIS.createTrait traitF, this.__proto__, null, []
        leaf  = Object.create this.__proto__, trait
        leaf

      newChild: () ->
        trait = THIS.createTrait traitF, this.__proto__, this, []
        leaf  = Object.create this.__proto__, trait
        this._childs.add leaf
        leaf
    }
    result._childs = { writable: false, value: objset.create(childs) }
    result._parent = { writable: true, value: parent }
    result._values = { writable: false, value: {} }
    result.locals  = { enumerable: true, get: () -> Object.keys this._values }
    result.root    = { enumerable: true, get: () -> p = this.parent; (p && p.root) || this }
    result.parent  = {
      enumerable: true
      get: () ->
        p = this._parent
        if (p && p._childs.has(this)) then p else null
      set: (newParent) ->
        return if this._parent == newParent
        throw new Error('Cyclic parent chain in leafy') if (newParent && newParent.isBelow(this))
        p = this._parent
        if newParent
          throw new Error('New parent with different prototype') if (newParent.__proto__ != this.__proto__)
          p._childs.remove(this) if (p && p._childs.has(this))
          newParent._childs.add(this)
          this._parent = newParent
        else
          p._childs.remove(this) if (p && p._childs.has(this))
          this._parent = newParent
    }
    result.childs = { enumerable: true, get: () -> this._childs.elems }
    (traitF && traitF(result)) || result

  createProto: (traitF = null) ->
    Object.create Object.prototype, this.createProtoTrait(traitF)

  create: (childs = [], traitF = null) ->
    this.create_ this.createProto(), childs, traitF

  create_: (proto, childs = [], traitF = null) ->
    Object.create proto, this.createTrait(traitF, proto, null, childs)
}


