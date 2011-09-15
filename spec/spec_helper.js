var moduleSpies = {};
var originalJsLoader = require.extensions['.js'];
process.env.NODE_ENV = "test";

spyOnModule = function spyOnModule(module, methods) {
  var path          = require.resolve(module);
  var spy           = createSpy("spy on module \"" + module + "\"");
  if(methods !== undefined) {
    for (var method in methods) {
      spy[methods[method]] = function () {
        return true 
      }
    }
  }

  moduleSpies[path] = spy;
  delete require.cache[path];
  return spy;
};

require.extensions['.js'] = function (obj, path) {
  if (moduleSpies[path])
    obj.exports = moduleSpies[path];
  else
    return originalJsLoader(obj, path);
}

afterEach(function() {
  for (var path in moduleSpies) {
    delete moduleSpies[path];
  }
});
var once, waitsForOnce;
waitsForOnce = function(message, timeout, thunk) {
  return waitsFor(message, timeout, once(false, thunk));
};
once = function(initialRetVal, thunk) {
  var retval, triggered, wrapper;
  triggered = false;
  retval = initialRetVal;
  return wrapper = function() {
    if (!triggered) {
      triggered = true;
      thunk(function(result) {
        return retval = result;
      });
    }
    return retval;
  };
};
