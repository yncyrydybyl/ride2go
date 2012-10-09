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

  it 'instances should support isRoot() and isChild() predicates', () ->
    r = leafy.create()
    c = r.newChild()
    expect(r.isRoot()).to.be.true
    expect(r.isChild()).to.be.false
    expect(c.isRoot()).to.be.false
    expect(c.isChild()).to.be.true

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
    expect(r.registeredProperties).to.eql(['foo', 'bar'])

  it 'prototype should support property installation', () ->
    r = leafy.create()
    r.installProperty('foo')
    r.installProperty('bar')
    expect(r.hasInstalledProperty('foo')).to.be.true
    expect(r.hasInstalledProperty('bar')).to.be.true
    expect(r.hasInstalledProperty('baz')).to.be.false
    expect(r.installedProperties).to.eql(['foo', 'bar'])

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

  it 'should inherit properties from its parent', () ->
    r     = leafy.create()
    r.installProperty 'foo'
    r.installProperty 'bar'
    a     = r.newChild()
    b     = r.newChild()
    r.foo = 20
    expect(r.foo).to.equal(20)
    expect(a.foo).to.equal(20)
    expect(b.foo).to.equal(20)

  it 'should write to undefined inherited properties', () ->
    r     = leafy.create()
    r.installProperty 'sip'
    a     = r.newChild()
    b     = r.newChild()
    b.sip = 42
    expect(r.sip).to.equal(undefined)
    expect(a.sip).to.equal(undefined)
    expect(b.sip).to.equal(42)
    expect(b.newChild().sip).to.equal(42)