__      = require 'underscore'
log     = require '../../lib/logging'

T       = require('traits').Trait
cloning = require '../../lib/base/cloning'
objset  = require '../../lib/base/objset'

protoProtoTrait = T {
  isBelow: (other) ->
    p = this.parent
    if p == other then true else  (if p then p.isBelow(other) else false)

  uproot: () ->
    this.parent = null

  isRoot: () ->
    this.parent == null

  isChild: () ->
    ! this.isRoot()

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
    this.installProperty(name) for name in this.registeredPropertyNames

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
    else
      if result
        # set property on root of copy of conflicting parent-tree
        result.dup().setProperty name, value
      else
        this

  allProperties: (result = {}) ->
    if this.isRoot()
      this.localProperties(result)
    else
      this.localProperties this.parent.allProperties()

  # copyChainBelow: (newParent) ->

  copyBelow: (newParent) ->
    leaf = newParent.newChild()
    for name, v of this._values
      leaf.setProperty name, v if v != undefined
    for child in this.childs
      child.copyBelow leaf
    return leaf

  dup: () ->
    if this.isRoot()
      top         = this.newRoot()
      leaf        = this.copyBelow top
      this.parent = top
      leaf
    else
      this.copyBelow this.parent

  childsAsJSON: (includeRegistered = false, includeInstalled = false) ->
    kids = this.childs # this is a fresh array
    i    = 0
    while i < kids.length
      kiddo   = kids[i]
      kids[i] = kiddo.asJSON includeRegistered, includeInstalled
      i       = i + 1
    kids

  asJSON: (includeRegistered = true, includeInstalled = false) ->
    result               = { values: this.localProperties() }
    result['registered'] = this.registeredPropertyNames if includeRegistered
    result['installed']  = this.installedPropertyNames if includeInstalled
    if !this.isLeaf()
      kids             = this.childsAsJSON(false, false)
      result['childs'] = kids
    result
}

protoProtoTrait.registeredPropertyNames = { enumerable: true, get: () -> this._register.elems }
protoProtoTrait.installedPropertyNames  = { enumerable: true, get: () -> this._installed.elems }

protoProto = Object.create Object.prototype, protoProtoTrait
protoProto.freeze

module.exports = T.object {
  createProtoTrait: (traitF) ->
    trait = {
      _register: { writable: false, value: objset.create() }
      _installed: { writable: false, value: objset.create() }
    }
    (traitF && traitF(trait)) || trait

  createTrait: (traitF, proto, parent, childs) ->
    THIS  = this
    trait = T {
      isLeaf: () ->
        this._childs.size == 0

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
        owner = this.trySetLocal name, value
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

      localProperties: (result = {}) ->
        for k, v of this._values
          result[k] = v if v != undefined
        result
    }
    trait._childs = { writable: false, value: objset.create(childs) }
    trait._parent = { writable: true, value: parent }
    trait._values = { writable: false, value: {} }
    trait.locals  = { enumerable: true, get: () -> Object.keys this._values }
    trait.root    = { enumerable: true, get: () -> p = this.parent; (p && p.root) || this }
    trait.parent  = {
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
    trait.childs = { enumerable: true, get: () -> this._childs.elems }
    (traitF && traitF(trait)) || trait

  createProto: (traitF = null) ->
    proto = Object.create protoProto, this.createProtoTrait(traitF)
    proto.freeze
    proto

  create: (childs = [], traitF = null) ->
    this.create_ this.createProto(), childs, traitF

  create_: (proto, childs = [], traitF = null) ->
    Object.create proto, this.createTrait(traitF, proto, null, childs)
}


