leafy = require '../../lib/base/leafy'
log   = require '../../lib/logging'

describe 'leafy', () ->

  it 'should support creating empty leafies', () ->
    expect(leafy.create()).to.be.ok

  it 'should support adding child leafies', () ->
    expect(leafy.create().newChild()).to.be.ok

  it 'instances should know their root', () ->
    root = leafy.create()
    expect(root.root).to.equal(root)
    expect(root.newChild().root).to.equal(root)
    expect(root.newChild().newChild().root).to.equal(root)

  it 'instances should support isRoot(), isLeaf() and isChild() predicates', () ->
    r = leafy.create()
    c = r.newChild()
    expect(r.isRoot()).to.be.true
    expect(r.isChild()).to.be.false
    expect(c.isRoot()).to.be.false
    expect(c.isChild()).to.be.true
    expect(r.isLeaf()).to.be.false
    expect(c.isLeaf()).to.be.true


  it 'instances should keep track of their childs', () ->
    root   = leafy.create()
    x      = root.newChild()
    x.name = 'x'
    y      = root.newChild()
    y.name = 'y'
    z      = y.newChild()
    z.name = 'z'
    expect(root.hasChild(x)).to.be.true
    expect(root.hasChild(y)).to.be.true
    expect(y.hasChild(z)).to.be.true

  it 'instances should allow chopping off of new roots', () ->
    root  = leafy.create()
    child = root.newChild()
    expect(root.root).to.equal(root)
    expect(root.parent).to.equal(null)
    expect(child.root).to.equal(root)
    expect(child.parent).to.equal(root)
    expect(root.hasChild(child)).to.be.true
    child.uproot()
    expect(root.hasChild(child)).to.not.be.true
    expect(root.root).to.equal(root)
    expect(root.parent).to.equal(null)
    expect(child.root).to.equal(child)
    expect(child.parent).to.equal(null)

  it 'instances should support the isBelow() predicate', () ->
    root = leafy.create()
    c0   = root.newChild()
    c1   = root.newChild()
    c2   = c1.newChild()
    c3   = c2.newChild()
    expect(root.isBelow(root)).to.be.false
    expect(c0.isBelow(root)).to.be.true
    expect(c1.isBelow(root)).to.be.true
    expect(c2.isBelow(root)).to.be.true
    expect(c3.isBelow(root)).to.be.true
    expect(c3.isBelow(c2)).to.be.true
    expect(c3.isBelow(c1)).to.be.true
    expect(c3.isBelow(c0)).to.be.false

  it 'root instances should have their own prototype by default', () ->
    a        = leafy.create()
    b        = leafy.create()
    expect(a.__proto__ != b.__proto__)

  it 'instances should support setting their parent', () ->
    r         = leafy.create()
    c0        = r.newChild()
    c1        = r.newChild()
    c2        = c0.newChild()
    c2.parent = c1
    expect(c2.parent == c1).to.be.true

  it 'instances should fail when setting a parent with a different prototype', () ->
    a   = leafy.create()
    b   = leafy.create()
    fn_ = () -> b.parent = a
    expect(a.__proto__ != b.__proto__)
    expect(fn_).to.throw(Error)
    # b.parent = a
    # expect(b.parent == a).to.be.true

  it 'instances should fail when creating cyclic parent chains', () ->
    r   = leafy.create()
    c0  = r.newChild()
    c1  = c0.newChild()
    fn_ = () -> c0.parent = c1
    expect(fn_).to.throw(Error)

  it 'prototype should support property registration', () ->
    r = leafy.create()
    r.registerProperty('foo')
    r.registerProperty('bar')
    expect(r.hasRegisteredProperty('foo')).to.be.true
    expect(r.hasRegisteredProperty('bar')).to.be.true
    expect(r.hasRegisteredProperty('baz')).to.be.false
    expect(r.registeredPropertyNames).to.eql(['foo', 'bar'])

  it 'prototype should support property installation', () ->
    r = leafy.create()
    r.installProperty('foo')
    r.installProperty('bar')
    expect(r.hasInstalledProperty('foo')).to.be.true
    expect(r.hasInstalledProperty('bar')).to.be.true
    expect(r.hasInstalledProperty('baz')).to.be.false
    expect(r.installedPropertyNames).to.eql(['foo', 'bar'])

  it 'prototype should register properties upon installation', () ->
    r = leafy.create()
    r.installProperty('foo')
    expect(r.hasInstalledProperty('foo')).to.be.true
    expect(r.hasRegisteredProperty('foo')).to.be.true

  it 'prototype should not fail when installing a property twice', () ->
    r = leafy.create()
    r.installProperty('foo')
    r.installProperty('foo')
    expect(r.hasInstalledProperty('foo')).to.be.true
    expect(r.hasRegisteredProperty('foo')).to.be.true

  it 'instances should support accessing installed properties', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    r.foo = 12
    r.bar = 13
    expect(r.foo).to.equal(12)
    expect(r.bar).to.equal(13)

  it 'instances should inherit properties from their parent', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    a     = r.newChild()
    b     = r.newChild()
    r.foo = 20
    expect(r.foo).to.equal(20)
    expect(a.foo).to.equal(20)
    expect(b.foo).to.equal(20)

  it 'instances should write to undefined inherited properties', () ->
    r     = leafy.create()
    r.installProperty 'sip'
    a     = r.newChild()
    b     = r.newChild()
    b.sip = 42
    expect(r.sip).to.equal(undefined)
    expect(a.sip).to.equal(undefined)
    expect(b.sip).to.equal(42)
    expect(b.newChild().sip).to.equal(42)

  it 'instances with childs should return fresh arrays', () ->
    r    = leafy.create()
    a    = r.newChild()
    b    = r.newChild()
    c    = r.childs
    c[0] = 'frodo'
    c[1] = 'bilbo'
    t    = r.childs
    expect(t[0]).to.not.equal('frodo')
    expect(t[1]).to.not.equal('frodo')
    expect(t[0]).to.not.equal('bilbo')
    expect(t[1]).to.not.equal('bilbo')

  it 'root instances should have a JSON representation', () ->
    r = leafy.create()
    expect(r.asJSON()).to.eql({ registered: [], values: {}})
    r.registerProperty 'foo'
    expect(r.asJSON()).to.eql({ registered: ['foo'], values: {}})
    r.setProperty 'foo', 12
    expect(r.asJSON()).to.eql({ registered: ['foo'], values: {foo: 12}})
    r.installProperty 'bar'
    expect(r.asJSON()).to.eql({
      registered: ['foo', 'bar'], values: {foo: 12}})
    expect(r.asJSON(true, true)).to.eql({
      registered: ['foo', 'bar'], installed: ['bar'], values: {foo: 12}})

  it 'complex instances childs\' should have a JSON representation', () ->
    r = leafy.create()
    a = r.newChild()
    expect(r.childsAsJSON()).to.eql([{ values: {} }])

  it 'instances with childs should have a JSON representation', () ->
    r = leafy.create()
    a = r.newChild()
    b = r.newChild()
    json = r.asJSON()
    expect(json).to.eql({
      registered: []
      values: []
      childs: [ { values: {} }, { values: {} } ]
    })

  it 'complex instances should have a JSON representation', () ->
    r        = leafy.create()
    a        = r.newChild()
    b        = r.newChild()
    c        = b.newChild()
    json     = r.asJSON()
    # console.log(JSON.stringify(json))
    expect(json).to.eql({
      registered: [],
      values: {},
      childs: [ {values: { } },{ values: {}, childs: [ { values: {} } ] } ]
    })

  it 'complex instances should support collecting all properties', () ->
    r        = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    r.installProperty 'baz'
    r.foo    = 100
    a        = r.newChild()
    a.bar    = 200
    b        = r.newChild()
    b.bar    = 300
    c        = b.newChild()
    c.baz    = 400
    # console.log(JSON.stringify(r.allProperties()))
    expect(r.allProperties()).to.eql({foo: 100})
    expect(a.allProperties()).to.eql({foo: 100, bar: 200})
    expect(b.allProperties()).to.eql({foo: 100, bar: 300})
    expect(c.allProperties()).to.eql({foo: 100, bar: 300, baz: 400})

  it 'instances can be copied below root', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    a     = r.newChild()
    a.foo = 67
    a.bar = 68
    b     = a.copyBelow(r)
    expect(b.allProperties()).to.eql({foo: 67, bar: 68})

  it 'complex instances can be copied below root', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    a     = r.newChild()
    a.foo = 67
    b     = a.newChild()
    b.bar = 68
    c     = a.copyBelow(r)
    expect(b.allProperties()).to.eql({foo: 67, bar: 68})
    expect(c.asJSON()).to.eql(a.asJSON())

  it 'instances should dup roots', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    r.foo = 72
    a     = r.newChild()
    a.bar = 74
    c     = r.dup()
    expect(a.allProperties()).to.eql({foo: 72, bar: 74})
    expect(r.asJSON()).to.eql(c.asJSON())
    expect(r.parent == c.parent).to.be.true
    expect(r.root   == c.root).to.be.true

  it 'instances should dup non-root leaves', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    a     = r.newChild()
    a.foo = 76
    b     = a.newChild()
    b.bar = 78
    c     = a.dup()
    expect(a.asJSON()).to.eql(c.asJSON())
    expect(a.parent).to.equal(r)
    expect(c.parent).to.equal(r)

  it.only 'instances should dup on conflicting set', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    r.foo = 80
    a     = r.newChild()
    a.bar = 82
    a.foo = 83
    expect(r.root.asJSON()).to.eql({
      values: {},
      registered: ['foo', 'bar'],
      childs: [
        { values: {foo:83}, childs: [ { values: {bar:82} } ] },
        { values: {foo:80}, childs: [ { values: {bar:82} } ] }
      ]
    })
