chai = require "chai"
chai.use(require("sinon-chai"))
chai.use(require("chai-as-promised"))
chai.use(require("chai-null"))
chai.use(require("chai-factories"))
chai.use(require("chai-http"))

# We use expect (and assert where that is more sensible) only
#
# global.should = chai.should
global.expect = chai.expect
global.assert = chai.assert

