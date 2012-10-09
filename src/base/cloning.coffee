T = require('traits').Trait

module.exports = T.object {
  trait: T {
    cloneTrait: T.required,

    clone: () ->
      Object.create this.__proto__, this.cloneTrait()
  }
}