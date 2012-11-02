// for tests in coffee script run via mocha/webstorm
require('coffee-script');

// configure testing DSL
var chai          = require("chai");
var chaiHttp      = require("chai-http");
var chaiSinon     = require("sinon-chai");
var chaiPromised  = require("chai-as-promised");
var chaiNull      = require("chai-null");
var chaiFactories = require("chai-factories");

chai.use(chaiHttp);
chai.use(chaiSinon);
chai.use(chaiPromised);
chai.use(chaiNull);
chai.use(chaiFactories);

// We export chai for chai-http
global.chai = chai;

// We use expect (and assert where that is more sensible) only
//
// global.should = chai.should
global.expect = chai.expect;
global.assert = chai.assert;


