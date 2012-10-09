// THIS IS A UTILITY SCRIPT FOR RUNNING TESTS VIA THE WEB STORM DEBUGGER ONLY
//
// Run this with working dir set to the project root
//
// The project test suite should be run via cake test before commit
//
var Mocha = require("mocha"),
    path  = require("path"),
    fs    = require("fs");

var testFiles= [
    "./test/test_helper.js"
];

var activeTests = require("./test/active_tests.js");

for (var i = 0; i<activeTests.length; i++) {
    var test = activeTests[i];
    testFiles.push(test);
}

var mocha = new Mocha;

mocha.reporter("spec").ui("bdd");

for (var i = 0; i<testFiles.length; i++) {
    var file = testFiles[i];
    mocha.addFile(file);
}

var passed = 0;
var failed = 0;

var runner = mocha.run(function () {
    console.log('finished');
    if (failed > 0) {
        process.exit(1);
    }
    else {
        process.exit(0);
    }
});

runner.on('pass', function (test) {
    passed = passed + 1;
    console.log('... %s passed', test.title);
});

runner.on('fail', function (test) {
    failed = failed + 1;
    console.log('... %s failed', test.title);
});