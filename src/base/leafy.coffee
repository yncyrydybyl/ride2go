__      = require '../../vendor/underscore'
log     = require '../../lib/logging'

T       = require('traits').Trait
cloning = require '../../lib/base/cloning'
objset  = require '../../lib/base/objset'



module.exports = T.object {
  createProtoTrait: (traitF) ->
    THIS  = this
    TRAIT = T {
      registerProperty: (name) ->
        this._register.add name
        name

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
        name

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
          throw new Error("Attempt to set unregistered property #{name}")
        if result
          throw new Error("Conflict")
        null

      childsAsJSON: (includeRegistered = false, includeInstalled = false) ->
        kids = this.childs # this is a fresh array
        i    = 0
        while i < kids.length
          kiddo   = kids[i]
          kids[i] = kiddo.asJSON includeRegistered, includeInstalled
          i       = i + 1
        kids

      asJSON: (includeRegistered = true, includeInstalled = false) ->
        result               = { values: this.valuesAsJSON() }
        result['registered'] = this.registeredProperties if includeRegistered
        result['installed']  = this.installedProperties if includeInstalled
        if !this.isLeaf()
          kids             = this.childsAsJSON(false, false)
          result['childs'] = kids
        result
    }
    TRAIT.registeredProperties = { enumerable: true, get: () -> this._register.elems }
    TRAIT.installedProperties  = { enumerable: true, get: () -> this._installed.elems }
    TRAIT._register  = { writable: false, value: objset.create() }
    TRAIT._installed = { writable: false, value: objset.create() }
    (traitF && traitF(TRAIT)) || TRAIT

  createTrait: (traitF, proto, parent, childs) ->
    THIS  = this
    TRAIT = T {
      isBelow: (other) ->
        p = this.parent
        if p == other then true else  (if p then p.isBelow(other) else false)

      isRoot: () ->
        this.parent == null

      isChild: () ->
        ! this.isRoot()

      isLeaf: () ->
        this._childs.size == 0

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

      dup: () ->
        if this.isRoot()
          top         = newRoot()
          this.parent = top
          this.dup()
        else
          null
          
      valuesAsJSON: (result = {}) ->
        for k, v of this._values
          result[k] = v if v != undefined
        result

      allValues: (result = {}) ->
        if this.isRoot()
          this.valuesAsJSON(result)
        else
          this.valuesAsJSON this._parent.allValues()
    }
    TRAIT._childs = { writable: false, value: objset.create(childs) }
    TRAIT._parent = { writable: true, value: parent }
    TRAIT._values = { writable: false, value: {} }
    TRAIT.locals  = { enumerable: true, get: () -> Object.keys this._values }
    TRAIT.root    = { enumerable: true, get: () -> p = this.parent; (p && p.root) || this }
    TRAIT.parent  = {
      enumerable: true
      get: () ->
        p = this._parent
        if (p && p._childs.has(this)) then p else null
      set: (newParent) ->
        return if this._parent == newParent
        if (newParent && newParent.isBelow(this))
          throw new Error('Cyclic parent chain in leafy')
        p = this._parent
        if newParent
          if (newParent.__proto__ != this.__proto__)
            throw new Error('New parent with different prototype')
          p._childs.remove(this) if (p && p._childs.has(this))
          newParent._childs.add(this)
          this._parent = newParent
        else
          p._childs.remove(this) if (p && p._childs.has(this))
          this._parent = newParent
    }
    TRAIT.childs = { enumerable: true, get: () -> this._childs.elems }
    (traitF && traitF(TRAIT)) || TRAIT

  createProto: (traitF = null) ->
    Object.create Object.prototype, this.createProtoTrait(traitF)

  create: (childs = [], traitF = null) ->
    this.create_ this.createProto(), childs, traitF

  create_: (proto, childs = [], traitF = null) ->
    Object.create proto, this.createTrait(traitF, proto, null, childs)
}


