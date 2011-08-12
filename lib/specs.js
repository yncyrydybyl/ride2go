require.paths.unshift("./");
var jasmine = require('jasmine-node');
var sys = require('sys');

for(var key in jasmine) {
  global[key] = jasmine[key];
}

var isVerbose = false;
var showColors = true;
var extentions = "js|coffee";
require("coffee-script");


process.argv.forEach(function(arg){
  switch(arg) {
  case '--color': showColors = true; break;
  case '--noColor': showColors = false; break;
  case '--verbose': isVerbose = true; break;
  case '--coffee': require('coffee-script');extentions = "js|coffee";break;
  }
});


jasmine.executeSpecsInFolder(__dirname + '/../spec', function(runner, log){
  process.exit(runner.results().failedCount);
}, isVerbose, showColors,new RegExp(".spec\\.(" + extentions + ")$", 'i'));
