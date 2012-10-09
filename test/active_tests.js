// configure tests
var selected_tests = {
    base: true
};

// result
var active_tests = [];

if (selected_tests.base) {
    active_tests.push("test/base/objset_test.coffee");
}

active_tests.push("test/base/leafy_test.coffee");

// export
module.exports = active_tests;
