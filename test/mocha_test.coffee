describe 'Mocha', () ->
  it 'should run unit tests', () ->
    expect(true).to.be.ok

  it 'should capture exceptions in tests', () ->
    expect(() -> throw new ReferenceError()).to.throw(ReferenceError)