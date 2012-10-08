T = require('traits').Trait

module.exports =  T {
  cloneTrait: T.required,

  buildClone: () ->
    T.create Object.prototype, this.cloneTrait()

  setupClone: (obj) ->
    obj

  clone: () ->
    this.setupClone(this.buildClone())
}
