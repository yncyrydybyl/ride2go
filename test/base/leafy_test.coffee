leafy = require '../../lib/base/leafy'
log   = require '../../lib/logging'

describe 'leafy', () ->

  it 'should support creating empty leafies', () ->
    expect(leafy.create()).to.be.ok

  it 'should support adding child leafies', () ->
    expect(leafy.create().newChild()).to.be.ok

  it 'should build leafies that know their root', () ->
    root = leafy.create()
    expect(root.root).to.equal(root)
    expect(root.newChild().root).to.equal(root)
    expect(root.newChild().newChild().root).to.equal(root)

  it 'should keep track of childs', () ->
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

  it 'should allow chopping off of new roots', () ->
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

  it 'should be able to figure if a node is below another', () ->
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

  it 'should support setting parent', () ->
    a        = leafy.create()
    b        = leafy.create()
    b.parent = a
    expect(b.parent == a).to.be.true