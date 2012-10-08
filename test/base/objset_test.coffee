objset = require '../../lib/base/objset'

describe 'objset', () ->

  it 'should create new emty sets', () ->
    set_ = objset.create()
    expect(set_).to.be.ok
    expect(set_.size).to.equal(0)
    expect(set_.has(4)).to.be.false

  it 'should create new non-empty sets', () ->
    set_ = objset.create [1, 2, 3]
    expect(set_).to.be.ok
    expect(set_.size).to.equal(3)
    expect(set_.has(1)).to.be.true
    expect(set_.has(2)).to.be.true
    expect(set_.has(3)).to.be.true
    expect(set_.has(4)).to.be.false

  it 'should support adding elements', () ->
    set_ = objset.create [4, 5]
    set_.add 6
    expect(set_.size).to.equal(3)
    expect(set_.has(4)).to.be.true
    expect(set_.has(5)).to.be.true
    expect(set_.has(6)).to.be.true
    expect(set_.has(7)).to.be.false

  it 'should support removing elements', () ->
    set_ = objset.create [7, 8, 9]
    set_.remove 7
    set_.remove 8
    expect(set_).to.be.ok
    expect(set_.size).to.equal(1)
    expect(set_.has(9)).to.be.true
    expect(set_.has(7)).to.be.false
    expect(set_.has(8)).to.be.false
    expect(set_.has(10)).to.be.false

  it 'should support cloning sets', () ->
    set_ = objset.create [11, 12, 13]
    cpy_ = set_.clone()
    expect(cpy_).to.be.ok
    expect(set_.size).to.equal(3)
    expect(cpy_.has(11)).to.be.true
    expect(cpy_.has(12)).to.be.true
    expect(cpy_.has(13)).to.be.true

  it 'should return new set when cloning', () ->
    set_ = objset.create [14, 15, 16]
    cpy_ = set_.clone()
    cpy_.remove 14
    expect(cpy_ == set_).to.be.false
    expect(set_.size).to.equal(3)
    expect(cpy_.size).to.equal(2)
    expect(set_.has(14)).to.be.true
    expect(set_.has(15)).to.be.true
    expect(set_.has(16)).to.be.true
    expect(cpy_.has(14)).to.be.false
    expect(cpy_.has(15)).to.be.true
    expect(cpy_.has(16)).to.be.true

  it 'should support double call to clone', () ->
    set_ = objset.create [17, 18, 19]
    set_ = set_.clone()
    set_.add 20
    set_ = set_.clone()
    expect(set_.size).to.equal(4)
