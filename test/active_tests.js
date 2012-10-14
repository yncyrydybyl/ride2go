// configure tests
var selected_tests = {
    base: true,
    place: true,
    ride: true,
    import: true,
    connectors: true
};

// result
var active_tests = [];

active_tests.push("test/mocha_test.coffee");

if (selected_tests.connectors) {
    active_tests.push("test/load_connectors_test.coffee");
    active_tests.push("test/connectors/deinbus_test.coffee");
    active_tests.push("test/connectors/pts_test.coffee");
//    active_tests.push("test/connectors/citynetz_test.coffee");
//    active_tests.push("test/connectors/geoname_test.coffee");
//    active_tests.push("test/connectors/mapquest_test.coffee");
//    active_tests.push("test/connectors/mitfahrzentrale_test.coffee");
//    active_tests.push("test/connectors/raummobil_test.coffee");
}

if (selected_tests.base) {
    active_tests.push("test/base/objset_test.coffee");
    active_tests.push("test/base/leafy_test.coffee");
}

if (selected_tests.place) {
    active_tests.push("test/place_test.coffee");
}

if (selected_tests.ride) {
    active_tests.push("test/ride_test.coffee");
}

if (selected_tests.import) {
    active_tests.push("test/geoname_import_test.coffee");
}

// export
module.exports = active_tests;
